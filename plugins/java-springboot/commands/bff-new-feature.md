---
description: Genera un feature completo para BFF Agent Chat Kaust Yotta a partir de un requerimiento o historia de usuario. Crea la cadena hexagonal reactiva completa adaptada al código real del proyecto. SIEMPRE hace discovery antes de generar. Usar cuando se trabaje en com.kaust.ms.manager.prompt y se reciba un requerimiento, HU o descripción funcional.
---

Genera un feature para **BFF Agent Chat Kaust Yotta** basado en:

---
$ARGUMENTS
---

> **Protocolo obligatorio — tres fases con dos pausas:**
> - Fase 1 (discovery) y Fase 2a (análisis) siempre se ejecutan primero.
> - **Pausa 1** se activa solo si hay preguntas que bloquean el diseño del árbol de archivos.
> - Fase 2b (diagnóstico completo) se ejecuta tras resolver las preguntas bloqueantes.
> - **Pausa 2** es siempre obligatoria — el usuario debe escribir `"generar"` para continuar.
> - Fase 3 (generación) solo se ejecuta tras esa autorización explícita.
> - No crear ningún archivo en ningún momento anterior a la Fase 3.

---

## FASE 1 — Discovery del proyecto real

Usar Read y Glob para leer el proyecto. No inferir convenciones — leerlas.

### 1.1 Estructura de dominios

**Glob** para listar todos los archivos Java del proyecto:
```
Glob("src/main/java/**/*.java")
```

Con el resultado:
- Confirmar que el paquete raíz es `com.kaust.ms.manager.prompt` o anotar el real
- Identificar los dominios presentes: `chat`, `settings`, `auth`, `report`, `shared`
- Determinar qué dominio tiene más archivos → será la referencia de convenciones
- Si `src/main/java/` no tiene archivos Java → activar **Fallback A** (ver al final)

### 1.2 Leer dependencias y stack

**Read** `build.gradle`:
- Versión de Java y Spring Boot
- Confirmar: `spring-boot-starter-webflux`, `spring-data-mongodb-reactive`
- Detectar: si MapStruct está declarado, versión de Spring AI, Firebase, GCP
- Anotar cualquier dependencia especial relevante para el feature

### 1.3 Leer exactamente un archivo por capa del dominio de referencia

Del dominio más desarrollado, leer **un archivo representativo por capa**:

| Capa | Qué leer |
|------|---------|
| Interfaz de caso de uso | cualquier `I<Name>UseCase.java` en `application/` |
| Implementación | cualquier UseCase en `application/usecases/` o `application/usecase/` |
| Modelo de dominio | cualquier clase en `domain/models/` |
| Puerto de salida | cualquier interfaz en `domain/ports/` |
| Documento MongoDB | cualquier `*Document.java` en `infrastructure/mongodb/documents/` |
| Repositorio Mongo | cualquier repositorio en `infrastructure/mongodb/repositories/` |
| Adaptador | cualquier adapter en `infrastructure/mongodb/adapters/` |
| Mapper | cualquier mapper en `infrastructure/mappers/` (si existe) |
| Controller | el controller más completo en `infrastructure/web/controllers/` |
| Shared | leer `shared/` completo: `@CurrentUser`, `UserData`, jerarquía de excepciones |

Anotar de cada archivo:
- Nombre exacto de la carpeta (¿es `usecases` o `usecase`?)
- Estilo de modelo: `record` o clase con Lombok
- Cómo se construye y lanza la excepción de dominio
- Si el controller usa `@CurrentUser UserData` y cómo
- Ruta base real de los endpoints (`/api/v1/`, `/v1/`, otro)

### 1.4 Leer infraestructura de tests

**Glob** `src/test/java/**/*.java` y leer:
- Clase base de test si existe
- Cómo se mockea `@CurrentUser` / `UserData` en tests existentes
- Si usan `@WebFluxTest` o `@SpringBootTest`
- Si hay helpers de `StepVerifier` o fixtures de datos de test

Si `src/test/java/` no tiene archivos → anotarlo.

### 1.5 Verificar si el feature ya existe parcialmente

Usar Glob para buscar el nombre del feature derivado del requerimiento:
```
Glob("src/**/*<Name>*")
```
Si se encuentran archivos → activar **Fallback B** (ver al final).

### 1.6 Detectar si el feature requiere streaming SSE

Del requerimiento, determinar si alguna operación devuelve datos en tiempo real o en stream. Anotar: SSE = sí / no. Si sí, el controller necesitará un endpoint con `produces = TEXT_EVENT_STREAM_VALUE` y el test usará `returnResult()` en lugar de `expectBody()`.

---

## FASE 2a — Análisis del requerimiento y preguntas bloqueantes

Derivar del requerimiento:

| Campo | Valor derivado |
|-------|---------------|
| Nombre del feature | sustantivo en PascalCase |
| Dominio destino | `chat` / `settings` / `auth` / `report` |
| Operaciones | lista de métodos del caso de uso con tipo `Mono<T>` o `Flux<T>` |
| Streaming SSE | sí / no (detectado en 1.6) |
| Persistencia | MongoDB / ninguna / externa |
| Integraciones externas | IA / correo / GCP / Firebase / JasperReports (si aplica) |
| Supuestos asumidos | todo lo inferido sin estar explícito en el requerimiento |

Identificar preguntas bloqueantes — aquellas cuya respuesta cambia el árbol de archivos o las firmas de los métodos:
- Ejemplos: ¿la lista es paginada o `Flux<T>` completo? ¿el campo X se persiste o es calculado? ¿hay más de un caso de uso o se agrupan en uno?

**Si hay preguntas bloqueantes → PAUSA 1.**
**Si no las hay → continuar directo a Fase 2b.**

---

## PAUSA 1 — Solo si hay preguntas bloqueantes

```
╔══════════════════════════════════════════════════════════════════╗
║  Antes de completar el diagnóstico necesito resolver:            ║
║                                                                  ║
║  [listar las preguntas bloqueantes aquí, numeradas]              ║
║                                                                  ║
║  Respóndelas para continuar con el plan completo.                ║
╚══════════════════════════════════════════════════════════════════╝
```

Esperar respuesta. Incorporarla y continuar a Fase 2b.

---

## FASE 2b — Diagnóstico completo

Con el discovery y el análisis completos, construir este reporte. No escribir archivos.

### 2.1 Convenciones reales detectadas

| Elemento | Skill (referencia) | Proyecto real (detectado) |
|----------|-------------------|--------------------------|
| Carpeta del caso de uso | `application/usecases/` | `<detectado>` |
| Nombre interfaz UseCase | `I<Name>UseCase` | `<detectado>` |
| Ubicación mappers | `infrastructure/mappers/` | `<detectado>` |
| Prefijo repositorio Mongo | `Mongo<Name>Repository` | `<detectado>` |
| Modelo de dominio | `record` | `<detectado>` |
| Excepción base | `ManagerPromptException` | `<detectado>` |
| Auth en controller | `@CurrentUser UserData` | `<detectado>` |
| Auth en tests | `@WithMockUser` | `<detectado>` |
| Ruta base API | `/api/v1/` | `<detectado>` |

**Desviaciones:** listar solo las filas donde "Proyecto real" difiere del "Skill", con el archivo de referencia donde se detectó.

### 2.2 Árbol de archivos — rutas reales, sin placeholders

Árbol completo con paquetes y carpetas exactamente como se leyeron en Fase 1. Cada archivo marcado como `[NUEVO]`, `[YA EXISTE — omitir]` o `[YA EXISTE — extender]`:

```
src/main/java/com/kaust/ms/manager/prompt/<dominio>/
├── application/
│   ├── I<Name>UseCase.java                        [NUEVO]
│   └── <carpeta-real-detectada>/
│       └── <Name>UseCase.java                     [NUEVO]
├── domain/
│   ├── models/
│   │   ├── <Name>.java                            [NUEVO]
│   │   ├── <Name>Request.java                     [NUEVO]
│   │   └── <Name>Response.java                    [NUEVO]
│   └── ports/
│       └── <Name>RepositoryPort.java              [NUEVO]
└── infrastructure/
    ├── web/controllers/
    │   └── <Name>Controller.java                  [NUEVO]
    │   (+ <Name>StreamController.java si SSE=sí)  [NUEVO]
    ├── mongodb/
    │   ├── documents/
    │   │   └── <Name>Document.java                [NUEVO]
    │   ├── repositories/
    │   │   └── <prefijo-real><Name>Repository.java [NUEVO]
    │   └── adapters/
    │       └── <Name>RepositoryAdapter.java        [NUEVO]
    └── mappers/
        └── <Name>DocumentMapper.java              [NUEVO / omitir si no hay MapStruct]

src/test/java/com/kaust/ms/manager/prompt/<dominio>/
├── application/<carpeta-real>/
│   └── <Name>UseCaseTest.java                    [NUEVO]
└── infrastructure/web/controllers/
    └── <Name>ControllerTest.java                  [NUEVO]
```

### 2.3 Conflictos y su resolución propuesta

Para cada conflicto:

```
CONFLICTO: <descripción>
  Archivo afectado: <ruta exacta>
  Opciones:
    A) <opción conservadora>
    B) <opción de reemplazo>
    C) Omitir este archivo
  Propuesta: A
```

Si no hay conflictos → "Sin conflictos detectados."

### 2.4 Dependencias faltantes

Si el feature necesita algo que no está en `build.gradle`, mostrar el bloque exacto:

```groovy
// Agregar a build.gradle
implementation 'org.example:librería:versión'
```

Y preguntar: *¿Quieres que lo agregue como parte de la generación?*

---

## PAUSA 2 — Siempre obligatoria

```
╔══════════════════════════════════════════════════════════════════╗
║  Diagnóstico completo. Ningún archivo ha sido creado.            ║
║                                                                  ║
║  Responde:                                                        ║
║  • "generar"            → proceder con el plan completo          ║
║  • "generar solo <capa>" → solo dominio / servicio /             ║
║                            controller / tests                    ║
║  • Corrección específica → se re-presenta el plan ajustado       ║
╚══════════════════════════════════════════════════════════════════╝
```

**Si el usuario da una corrección:** aplicarla, re-mostrar solo las secciones 2.2 y 2.3 actualizadas, y volver a la Pausa 2. No generar nada.

**Si el usuario escribe "generar" o variante afirmativa:** continuar a Fase 3.

---

## FASE 3 — Generación

Generar cada archivo en el orden del árbol de 2.2. Mostrar la ruta completa como header antes de cada bloque de código. Omitir los marcados `[YA EXISTE — omitir]`.

### Orden de generación

1. Modelos de dominio (`domain/models/`)
2. Puerto de salida (`domain/ports/`) — si hay persistencia
3. Interfaz del caso de uso (`application/`)
4. Implementación del caso de uso (carpeta real detectada)
5. Documento MongoDB (`infrastructure/mongodb/documents/`)
6. Repositorio Mongo (`infrastructure/mongodb/repositories/`)
7. Mapper (`infrastructure/mappers/`) — solo si MapStruct está en `build.gradle`
8. Adaptador de persistencia (`infrastructure/mongodb/adapters/`)
9. Controller REST (`infrastructure/web/controllers/`)
10. Controller SSE (si SSE = sí) — endpoint separado con `produces = TEXT_EVENT_STREAM_VALUE`
11. Test del caso de uso — con `StepVerifier`
12. Test del controller — con `WebTestClient`; si SSE: `returnResult(String.class).getResponseBody()`

Si el usuario pidió "generar solo <capa>", generar únicamente los archivos de esa capa.

### Reglas de generación

- Paquetes: exactamente los detectados en 1.3 — ni un carácter diferente
- Carpeta de casos de uso: la detectada (no asumir `usecases/` vs `usecase/`)
- Modelo: `record` si el proyecto lo usa, `@Data @Builder` si usa Lombok — lo que se detectó
- Excepción: la clase exacta detectada en `shared/`; nunca inventar una nueva
- Auth: `@CurrentUser UserData` exactamente como aparece en los controllers existentes
- Tests: extender clase base si existe; usar el mismo mecanismo de mock de `@CurrentUser`
- Mapper: solo si MapStruct está declarado; si no, mapeo manual inline en el adapter
- OpenAPI: `@Tag`, `@Operation`, `@ApiResponse` con la misma estructura que los controllers leídos

### Checklist pre-entrega

Antes de mostrar el output final, verificar:

- [ ] Paquetes y carpetas coinciden con los detectados en Fase 1 (no son del skill)
- [ ] `domain/` no importa nada de `org.springframework.data`, WebFlux ni frameworks de IA
- [ ] Toda la cadena usa `Mono`/`Flux` de principio a fin
- [ ] Ningún método de la cadena reactiva hace una llamada bloqueante
- [ ] El controller delega únicamente a `I<Name>UseCase` — cero lógica de negocio
- [ ] El adaptador MongoDB nunca expone `<Name>Document` fuera de `infrastructure/`
- [ ] Los errores usan la excepción detectada en `shared/`
- [ ] Los tests usan el mismo mecanismo de auth detectado en Fase 1
- [ ] Los archivos marcados `[YA EXISTE — omitir]` no fueron generados
- [ ] Los conflictos de 2.3 se resolvieron con la opción indicada

Si algún punto falla, corregirlo antes de mostrar el output.

---

## Fallbacks

### Fallback A — Proyecto sin archivos Java existentes

Si Glob no encuentra archivos en `src/main/java/`:

```
╔══════════════════════════════════════════════════════════════════╗
║  No se encontraron archivos Java en src/main/java/.              ║
║  El proyecto parece estar vacío o no inicializado.               ║
║                                                                  ║
║  Para proyectos nuevos, usar primero:                            ║
║    /java-springboot:new-project <nombre>                         ║
║                                                                  ║
║  Si el código está en otra ruta, indícala.                       ║
╚══════════════════════════════════════════════════════════════════╝
```

Detener. No continuar.

### Fallback B — Feature ya existe parcialmente

Si Glob encuentra archivos con el nombre del feature:

```
ATENCIÓN: Ya existen archivos relacionados con "<Name>":
  - <ruta/Archivo1.java>  → <descripción de una línea de su contenido>
  - <ruta/Archivo2.java>  → <descripción de una línea de su contenido>

¿Qué hacer?
  A) Extender los existentes con las nuevas operaciones del requerimiento
  B) Generar solo los archivos que faltan (omitir los existentes)
  C) Cancelar y revisar manualmente
```

Esperar respuesta antes de continuar al diagnóstico completo.
