---
name: bff-agent-chat-kaust-yotta
description: |
  BFF Agent Chat Kaust Yotta — convenciones de arquitectura, naming, stack y patrones del proyecto.

  USAR CUANDO: se trabaje en el repositorio bff-agent-chat-kaust-yotta, se mencione "kaust", "MsManagerPrompt",
  "bff-agent-chat", se cree o modifique código en com.kaust.ms.manager.prompt, o se hable de casos de uso
  reactivos con WebFlux + MongoDB en este microservicio.

  NO USAR PARA: otros proyectos Spring Boot genéricos (usar spring-boot, spring-webflux o hexagonal-architecture-layers-java).
allowed-tools: Read, Grep, Glob, Write, Edit
---

# BFF Agent Chat — Kaust Yotta

Microservicio reactivo que orquesta chat, historial, contexto de prompts, exportación PDF y envío de correo
sobre modelos de IA. Stack: **Java 17 · Spring Boot + WebFlux · Spring Data MongoDB Reactive · Gradle**.

---

## Stack completo

| Capa | Tecnología |
|------|-----------|
| Lenguaje | Java 17 (Gradle toolchain) |
| Web | Spring WebFlux (reactivo) |
| Persistencia | Spring Data MongoDB Reactive |
| Seguridad | Spring Security reactive + Firebase |
| IA | Spring AI (OpenAI) |
| Plantillas | FreeMarker · Thymeleaf (mail) |
| Reportes | JasperReports |
| API Docs | SpringDoc OpenAPI (Swagger) |
| Utilidades | Lombok (`@RequiredArgsConstructor`) · MapStruct |
| Calidad | Spotless (Google Java Format 1.17.0) · PMD · SpotBugs · ArchUnit |

Comando de build estándar: `./gradlew spotlessApply build`

---

## Paquete raíz y dominios

Raíz fija: `com.kaust.ms.manager.prompt`

| Dominio | Responsabilidad |
|---------|----------------|
| `chat` | Streaming IA, mensajes, carpetas, historial, exportación PDF/correo, persistencia de conversaciones |
| `settings` | Modelos de IA y configuración del sistema |
| `auth` | Usuario, Firebase, seguridad WebFlux |
| `report` | Generación de reportes (JasperReports) |
| `shared` | Config transversal, `@CurrentUser`, `UserData`, excepciones comunes |

---

## Estructura hexagonal por dominio

```
com.kaust.ms.manager.prompt/<dominio>/
├── application/
│   ├── I<Name>UseCase.java          ← contrato (interfaz) expuesto al adaptador de entrada
│   └── usecases/
│       └── <Name>UseCase.java       ← implementación del caso de uso
├── domain/
│   ├── models/                      ← entidades, DTOs de dominio, requests, responses
│   ├── enums/
│   └── ports/                       ← interfaces de salida (repositorios, clientes IA, etc.)
└── infrastructure/
    ├── web/controllers/             ← @RestController WebFlux
    ├── mongodb/
    │   ├── documents/               ← <Name>Document.java
    │   ├── repositories/            ← ReactiveMongoRepository
    │   └── adapters/                ← implementan ports del dominio
    ├── ia/adapters/
    ├── mail/
    ├── freemarker/
    ├── gcp/
    ├── firebase/
    ├── jasperreport/
    └── mappers/
```

**Flujo de dependencias obligatorio:**
```
infrastructure → application → domain
domain NO depende de ninguna capa externa
```

---

## Convenciones de nombres

### Interfaces y clases

| Artefacto | Patrón | Ejemplo |
|-----------|--------|---------|
| Interfaz de caso de uso | `I<Name>UseCase` | `IProcessChatMessageStreamUseCase` |
| Implementación de caso de uso | `<Name>UseCase` | `ProcessChatMessageStreamUseCase` |
| Controlador | `<Name>Controller` | `StreamController`, `FolderController` |
| Documento MongoDB | `<Name>Document` | `ChatDocument`, `MessageDocument` |
| Puerto de salida | `<Name>Port` | `ReactiveRagChatPort` |
| DTOs | sufijo `Request` / `Response` | `MessageRequest`, `ChatMessageResponse` |
| Excepciones | en `shared` | `ManagerPromptException`, `ManagerPromptError` |

### Paquetes y archivos
- Paquetes: `minúsculas` (`usecases`, `mongodb`, `controllers`)
- Clases: `PascalCase` coincide con el nombre del archivo
- Métodos / variables: `camelCase`
- Constantes: `UPPER_SNAKE_CASE`

---

## Patrones reactivos — reglas críticas

```java
// ✅ CORRECTO — toda la cadena es reactiva
Flux<ChatMessageResponse> execute(String userId, MessageRequest request);

// ❌ MAL — llamada bloqueante dentro de cadena reactiva
Mono.fromCallable(() -> mongoRepo.findById(id)); // bloquea el event loop

// ✅ FIX — delegar a scheduler bounded elastic si es inevitable
Mono.fromCallable(() -> blockingCall())
    .subscribeOn(Schedulers.boundedElastic());
```

- `Mono<T>` para 0..1 resultados, `Flux<T>` para 0..N
- Streaming SSE en controllers: `produces = MediaType.TEXT_EVENT_STREAM_VALUE`
- No mezclar tipos bloqueantes en la cadena del caso de uso

---

## Controller — estructura estándar

```java
@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
@Tag(name = "Chat", description = "Chat management and AI streaming")
public class ChatController {

    private final IProcessChatMessageStreamUseCase processStreamUseCase;

    @Operation(summary = "Stream chat response", responses = {
        @ApiResponse(responseCode = "200", description = "SSE stream"),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @PostMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ChatMessageResponse> streamChat(
            @CurrentUser UserData user,
            @Valid @RequestBody MessageRequest request) {
        return processStreamUseCase.execute(user.getId(), request);
    }
}
```

**Reglas del controller:**
- Delgado: solo mapea HTTP → caso de uso → respuesta
- Sin lógica de negocio, sin acceso directo a repositorios
- `@CurrentUser UserData` para obtener el usuario autenticado
- `@Valid` en `@RequestBody` con `jakarta.validation`
- `@Tag`, `@Operation`, `@ApiResponse` en cada endpoint

---

## Caso de uso — estructura estándar

```java
// Interfaz en application/
public interface IGetChatByIdUseCase {
    Mono<ChatResponse> execute(String userId, String chatId);
}

// Implementación en application/usecases/
@Service
@RequiredArgsConstructor
public class GetChatByIdUseCase implements IGetChatByIdUseCase {

    private static final Logger log = LoggerFactory.getLogger(GetChatByIdUseCase.class);
    private final ChatRepositoryPort chatRepository;  // puerto, no repositorio Mongo

    @Override
    public Mono<ChatResponse> execute(String userId, String chatId) {
        return chatRepository.findByIdAndUserId(chatId, userId)
            .switchIfEmpty(Mono.error(new ManagerPromptException("Chat not found")))
            .map(this::toResponse)
            .doOnError(e -> log.error("Error retrieving chat {}: {}", chatId, e.getMessage()));
    }
}
```

---

## Puerto de salida — estructura estándar

```java
// En domain/ports/
public interface ChatRepositoryPort {
    Mono<Chat> findByIdAndUserId(String chatId, String userId);
    Flux<Chat> findAllByUserId(String userId);
    Mono<Chat> save(Chat chat);
    Mono<Void> deleteById(String chatId);
}

// Implementación en infrastructure/mongodb/adapters/
@Component
@RequiredArgsConstructor
public class ChatRepositoryAdapter implements ChatRepositoryPort {

    private final MongoChatRepository mongoRepo;   // ReactiveMongoRepository
    private final ChatDocumentMapper mapper;        // MapStruct

    @Override
    public Mono<Chat> findByIdAndUserId(String chatId, String userId) {
        return mongoRepo.findByIdAndUserId(chatId, userId)
            .map(mapper::toDomain);
    }
}
```

**Regla:** el dominio recibe y devuelve modelos de dominio (`Chat`), nunca `ChatDocument`.

---

## Documento MongoDB — estructura estándar

```java
// En infrastructure/mongodb/documents/
@Document(collection = "chats")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatDocument {

    @Id
    private String id;
    private String userId;
    private String title;
    private Instant createdAt;
    private Instant updatedAt;
    private List<String> messageIds;
}
```

---

## Manejo de errores

- Jerarquía centralizada en `shared`: `ManagerPromptException`, `ManagerPromptError`
- No silenciar excepciones: propagar o mapear a señal reactiva (`Mono.error(...)`)
- No usar excepciones para control de flujo ordinario — usar `switchIfEmpty`, `filter`, `defaultIfEmpty`
- Logging: SLF4J/Logback, nunca `System.out`
- Respuestas HTTP de error: mapear en `@ControllerAdvice` reactivo a `ProblemDetail` o estructura acordada

```java
// ✅ Propagación correcta en cadena reactiva
.switchIfEmpty(Mono.error(new ManagerPromptException("Resource not found")))

// ❌ No lanzar excepciones checked en lambdas reactivas sin manejo
.map(doc -> { throw new RuntimeException(); }) // rompe la cadena sin onError
```

---

## Calidad y formato

- **Spotless** aplica Google Java Format 1.17.0 automáticamente: `./gradlew spotlessApply`
- **PMD**: reglas en `config/pmd/ruleset.xml` — no añadir supresiones sin justificación
- **SpotBugs**: exclusiones en `config/spotbugs/exclude.xml`
- **ArchUnit**: tests de arquitectura validan que `domain` no depende de `infrastructure`
- Imports: dejar que Spotless unifique (no ordenar manualmente)
- Un tipo público principal por archivo

---

## Documentación

```java
/**
 * Procesa el flujo de mensajes de chat en modo streaming.
 *
 * @param userId identificador del usuario autenticado
 * @param request cuerpo validado de la petición
 * @return flujo de fragmentos de respuesta del asistente
 */
Flux<ChatMessageResponse> execute(String userId, MessageRequest request);
```

- Javadoc en APIs públicas no triviales: parámetros, retornos, efectos laterales
- Comentarios inline solo cuando el nombre no sea suficiente
- OpenAPI en todos los controllers con `@Tag`, `@Operation`, `@ApiResponse`

---

## Checklist antes de generar código en este proyecto

- [ ] ¿El caso de uso tiene interfaz `I<Name>UseCase` en `application/`?
- [ ] ¿La implementación está en `application/usecases/`?
- [ ] ¿El puerto de salida está en `domain/ports/` y su adaptador en `infrastructure/`?
- [ ] ¿La cadena es completamente reactiva (`Mono`/`Flux`) de principio a fin?
- [ ] ¿El dominio (`domain/`) no importa nada de `org.springframework.data`, WebFlux o IA?
- [ ] ¿El controller usa `@CurrentUser UserData` y delega todo al caso de uso?
- [ ] ¿Los documentos MongoDB están en `infrastructure/mongodb/documents/`?
- [ ] ¿Los errores usan `ManagerPromptException` / `ManagerPromptError` de `shared`?
- [ ] ¿Hay `@Tag`, `@Operation`, `@ApiResponse` en el controller?
