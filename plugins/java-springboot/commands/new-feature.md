---
description: Genera un feature completo para cualquier proyecto Spring Boot a partir de un requerimiento o historia de usuario. Se adapta a la arquitectura real del proyecto (capas, hexagonal, DDD), persistencia (JPA/MongoDB/JDBC/R2DBC) y capa web (MVC/WebFlux). SIEMPRE hace discovery del proyecto real antes de generar — nunca aplica templates sin leer primero. Usar cuando se reciba un requerimiento, HU o descripción funcional en un proyecto Spring Boot.
---

Genera un feature Spring Boot basado en:

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

Usar las herramientas Read y Glob para leer el proyecto. No inferir ni asumir convenciones.

### 1.1 Detectar el tipo de proyecto

**Usar Glob** para listar todos los archivos Java:
```
Glob("src/main/java/**/*.java")
```

Con el resultado:
- Encontrar la clase `*Application.java` → extraer el paquete raíz exacto
- Determinar el estilo arquitectónico por los nombres de paquete:
  - **Capas**: carpetas `controller/`, `service/`, `repository/`, `entity/`, `dto/`
  - **Hexagonal**: carpetas `domain/`, `application/`, `infrastructure/`, `port/`, `adapter/`
  - **DDD modular**: organizado por dominio primero, luego por capa dentro de cada módulo
- Si `src/main/java/` no tiene archivos Java → activar **Fallback A** (ver al final)

### 1.2 Leer dependencias y stack

**Read** `pom.xml` o `build.gradle` / `build.gradle.kts`:

Extraer y anotar:
- Versión de Java y Spring Boot
- Capa web: `spring-boot-starter-web` (MVC) o `spring-boot-starter-webflux` (reactivo)
- Persistencia: `spring-data-jpa` / `spring-data-mongodb` / `spring-data-jdbc` / `spring-data-r2dbc`
- Presentes: Lombok, MapStruct, Flyway, Liquibase, Validation, Security, springdoc-openapi
- Tests: Testcontainers, AssertJ, Awaitility

### 1.3 Leer exactamente un archivo por capa del feature de referencia

Identificar el dominio o módulo con más archivos (el más desarrollado). Leer **un archivo representativo por capa** — no todos:

| Capa | Archivo a leer |
|------|---------------|
| Entidad / modelo de dominio | el archivo más simple del dominio (sin dependencias externas) |
| Repositorio / puerto de salida | cualquier interfaz de repositorio existente |
| Servicio / caso de uso | la implementación de servicio o caso de uso más corta |
| Controller | el controller con más endpoints |
| DTO | cualquier Request o Response existente |
| Mapper | cualquier mapper MapStruct (si existe) |
| Test de servicio | cualquier test unitario de servicio |
| Test de controller | cualquier test de controller |

Anotar de cada archivo leído:
- Nombre exacto del paquete
- Nombre exacto de la carpeta dentro de `src/main/java/`
- Estilo de clase: `record`, `@Data`, `@Builder`, clase plana
- Patrón de manejo de errores: qué excepción lanza, desde dónde
- Patrón de logging: SLF4J estático, Lombok `@Slf4j`, otro

Si no existe alguna de estas capas → anotarlo como "no detectado" (no asumir).

### 1.4 Leer infraestructura de tests

**Glob** `src/test/java/**/*.java` y leer:
- Clase base de test si existe (`Abstract*`, `Base*`)
- Cómo se configura security en tests (anotación, mock, deshabilitado)
- Si hay Testcontainers: cómo se declara el container (singleton estático, por clase)
- Librería de assertions usada (AssertJ `assertThat`, Hamcrest `assertThat`, JUnit básico)

Si `src/test/java/` no tiene archivos → anotarlo como "tests no encontrados".

### 1.5 Verificar archivos que ya podrían existir para este feature

Antes de diseñar el árbol, usar Glob para verificar si ya existe algo relacionado con el nombre del feature derivado del requerimiento:
```
Glob("src/**/*<Name>*")
```
Si se encuentran archivos → activar **Fallback B** (ver al final).

---

## FASE 2a — Análisis del requerimiento y preguntas bloqueantes

Derivar del requerimiento:

| Campo | Valor derivado |
|-------|---------------|
| Nombre del feature | sustantivo en PascalCase |
| Operaciones | lista de acciones del caso de uso |
| Tipo de respuesta | síncrono / reactivo (Mono/Flux) — según stack detectado |
| Persistencia | tipo detectado en 1.2 / ninguna |
| Auth requerida | sí / no — según security en el proyecto |
| Supuestos asumidos | todo lo inferido sin estar en el requerimiento |

Identificar preguntas que bloquean el diseño del árbol. Son bloqueantes si su respuesta cambia:
- El número de archivos a generar
- La firma de los métodos del caso de uso
- La estructura de los DTOs

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

Esperar respuesta. Incorporar las respuestas al análisis y continuar a Fase 2b.

---

## FASE 2b — Diagnóstico completo

Con el discovery y el análisis completos, construir este reporte. No escribir archivos.

### 2.1 Stack y convenciones detectadas

| Elemento | Detectado |
|----------|-----------|
| Paquete raíz | `com.ejemplo.app` (valor real) |
| Arquitectura | Capas / Hexagonal / DDD modular |
| Capa web | Spring MVC / WebFlux |
| Persistencia | JPA + PostgreSQL / MongoDB / JDBC / R2DBC |
| Migración | Flyway / Liquibase / ninguna |
| MapStruct | presente / ausente |
| Patrón de modelo | `record` / `@Data @Builder` / clase plana |
| Patrón de error | nombre de la excepción detectada |
| Test slice | `@WebMvcTest` / `@WebFluxTest` / `@SpringBootTest` |
| Base class test | nombre si existe / ninguna |
| Dependencias faltantes | lista de lo que necesita el feature y no está en el build file |

### 2.2 Desviaciones respecto a defaults de Spring Boot

Listar solo las convenciones que difieren de lo esperado, con el archivo de referencia donde se detectaron. Si todo es estándar, escribir "ninguna desviación".

### 2.3 Árbol de archivos — rutas reales, sin placeholders

Mostrar el árbol completo con rutas absolutas relativas a la raíz del proyecto. Cada archivo marcado como `[NUEVO]`, `[YA EXISTE — omitir]` o `[YA EXISTE — extender]`:

```
src/main/java/<paquete-raíz-real>/<ruta-real>/
├── <carpeta-real-detectada>/
│   └── <NombreReal>UseCase.java          [NUEVO]
...

src/test/java/<paquete-raíz-real>/<ruta-real>/
├── <NombreReal>UseCaseTest.java          [NUEVO]
...

src/main/resources/db/migration/          (si Flyway)
└── V<n+1>__create_<tabla>.sql            [NUEVO]
```

Usar los nombres de carpeta y paquete exactamente como se leyeron en Fase 1.

### 2.4 Conflictos y su resolución propuesta

Para cada conflicto detectado, mostrar opciones:

```
CONFLICTO: <descripción>
  Archivo afectado: <ruta>
  Opciones:
    A) <opción conservadora>
    B) <opción de reemplazo>
    C) Omitir este archivo y crearlo manualmente
  Propuesta: A  ← indicar cuál se usará si el usuario escribe "generar" sin especificar
```

Si no hay conflictos → escribir "Sin conflictos detectados."

### 2.5 Dependencias faltantes

Si el feature necesita algo que no está en el build file, mostrar el bloque exacto a agregar:

```xml
<!-- Agregar a pom.xml -->
<dependency>
    <groupId>...</groupId>
    <artifactId>...</artifactId>
</dependency>
```

O en Gradle. Preguntar: *¿Quieres que lo agregue como parte de la generación?*

---

## PAUSA 2 — Siempre obligatoria

```
╔══════════════════════════════════════════════════════════════════╗
║  Diagnóstico completo. Ningún archivo ha sido creado.            ║
║                                                                  ║
║  Responde:                                                        ║
║  • "generar"            → proceder con el plan completo          ║
║  • "generar solo <capa>" → generar solo dominio / servicio /     ║
║                            controller / tests                    ║
║  • Corrección específica → se re-presenta el plan ajustado       ║
╚══════════════════════════════════════════════════════════════════╝
```

**Si el usuario da una corrección:** aplicarla, re-mostrar solo la sección 2.3 y 2.4 actualizadas, y volver a mostrar la Pausa 2. No generar nada.

**Si el usuario escribe "generar" o variante afirmativa ("sí generar", "procede", "adelante"):** continuar a Fase 3.

---

## FASE 3 — Generación

Generar cada archivo en el orden del árbol de 2.3. Mostrar la ruta completa como header antes de cada bloque de código. Usar las convenciones exactas detectadas en Fase 1 — no los defaults del skill.

### Orden de generación

1. Entidad / modelo de dominio
2. Puerto de salida / repositorio (si hay persistencia)
3. Interfaz del caso de uso / servicio (si el proyecto usa interfaces)
4. Implementación del caso de uso / servicio
5. DTOs: Request, Response
6. Mapper (solo si MapStruct está presente en el proyecto)
7. Adaptador de persistencia (si arquitectura hexagonal)
8. Controller
9. Script de migración (si Flyway/Liquibase)
10. Test unitario del servicio / caso de uso
11. Test de controller (slice)
12. Test de repositorio / persistencia (si el proyecto tiene tests de este tipo)

Si el usuario pidió "generar solo <capa>", generar únicamente los archivos de esa capa.

### Reglas de generación

- Paquetes: exactamente los detectados en 1.3 — ni un carácter diferente
- Modelo: `record` si el proyecto usa records, `@Data @Builder` si usa Lombok, lo que se detectó
- Excepciones: la misma clase detectada en 1.3, no inventar una nueva
- Logging: el mismo patrón detectado (SLF4J estático o `@Slf4j`)
- Tests: extender la clase base si existe; no duplicar su configuración
- Tests: usar la misma librería de assertions detectada (AssertJ / Hamcrest)
- Tests reactivos: `StepVerifier` si la capa web es WebFlux
- Mapper: solo si MapStruct está en el build file; si no, mapeo manual inline
- OpenAPI: solo si el proyecto ya usa `@Tag`, `@Operation`
- Migration: versión `V<n+1>` donde `n` es el número más alto encontrado en `db/migration/`

### Checklist pre-entrega

Antes de mostrar el output final:

- [ ] Todos los paquetes coinciden exactamente con los detectados en Fase 1
- [ ] Ningún import referencia una clase que no exista en este proyecto
- [ ] No se asumió ninguna dependencia que no esté en el build file
- [ ] Los archivos marcados `[YA EXISTE — omitir]` no fueron generados
- [ ] Los conflictos de 2.4 se resolvieron con la opción indicada (o la propuesta si el usuario no especificó)
- [ ] El script de migración usa el número de versión correcto

Si algún punto falla, corregirlo antes de mostrar el output.

---

## Fallbacks

### Fallback A — Proyecto sin archivos Java existentes

Si Glob no encuentra archivos Java en `src/main/java/`:

```
╔══════════════════════════════════════════════════════════════════╗
║  No se encontraron archivos Java en src/main/java/.              ║
║  Este parece ser un proyecto nuevo o vacío.                      ║
║                                                                  ║
║  Para proyectos nuevos, usar primero:                            ║
║    /java-springboot:new-project <nombre>                         ║
║                                                                  ║
║  Si el proyecto ya existe pero está en otra ruta, indícala.      ║
╚══════════════════════════════════════════════════════════════════╝
```

Detener el comando. No continuar con la generación.

### Fallback B — Feature ya existe parcialmente

Si Glob encuentra archivos con el nombre del feature:

```
ATENCIÓN: Ya existen archivos relacionados con "<Name>":
  - <ruta/archivo1.java>  [contenido: <resumen de una línea>]
  - <ruta/archivo2.java>  [contenido: <resumen de una línea>]

¿Qué hacer?
  A) Extender los existentes con las nuevas operaciones del requerimiento
  B) Regenerar solo los archivos que faltan (omitir los existentes)
  C) Cancelar y revisar manualmente
```

Esperar respuesta antes de continuar al diagnóstico completo.
