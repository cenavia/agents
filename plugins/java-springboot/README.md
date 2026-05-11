# Java Spring Boot Plugin for Claude Code

A comprehensive Java and Spring Boot development toolkit for Claude Code. This plugin provides 74 skills covering the full Spring ecosystem — from core Java to microservices, security, data access, messaging, testing, DevOps, and AI integration.

## Installation

```bash
# From the marketplace
claude plugin install java-springboot@marketplace

# From a local directory
claude --plugin-dir ./java-springboot-plugin
```

## Skills Reference

Invoke any skill using the `/java-springboot:<skill-name>` syntax.

### Core Java

| Skill | Invocation | Description |
|-------|-----------|-------------|
| java | `/java-springboot:java` | Java 17+ features, patterns, and best practices |
| java-quality | `/java-springboot:java-quality` | Checkstyle, SpotBugs, PMD, and SonarJava |
| java-logging | `/java-springboot:java-logging` | SLF4J, Logback, Log4j2, structured logging |
| java-profiling | `/java-springboot:java-profiling` | JVM profiling with JFR, jcmd, GC tuning |
| java-security | `/java-springboot:java-security` | Java and Spring Boot secure coding patterns |
| java-foreign | `/java-springboot:java-foreign` | Foreign Function & Memory API (Project Panama) |
| java-docs | `/java-springboot:java-docs` | Javadoc best practices |
| java-junit | `/java-springboot:java-junit` | JUnit 5 unit testing best practices |
| java-refactoring-extract-method | `/java-springboot:java-refactoring-extract-method` | Extract Method refactoring patterns |
| java-refactoring-remove-parameter | `/java-springboot:java-refactoring-remove-parameter` | Remove Parameter refactoring patterns |
| java-add-graalvm-native-image-support | `/java-springboot:java-add-graalvm-native-image-support` | GraalVM Native Image support |

### Spring Boot Core

| Skill | Invocation | Description |
|-------|-----------|-------------|
| spring-boot | `/java-springboot:spring-boot` | Spring Boot 3 enterprise patterns |
| spring-boot-project-creator | `/java-springboot:spring-boot-project-creator` | Scaffold new Spring Boot projects |
| spring-boot-crud-patterns | `/java-springboot:spring-boot-crud-patterns` | CRUD REST API patterns |
| spring-boot-dependency-injection | `/java-springboot:spring-boot-dependency-injection` | Dependency injection patterns |
| spring-boot-rest-api-standards | `/java-springboot:spring-boot-rest-api-standards` | REST API design standards |
| spring-boot-actuator | `/java-springboot:spring-boot-actuator` | Actuator health checks and metrics |
| spring-boot-cache | `/java-springboot:spring-boot-cache` | Caching patterns |
| spring-boot-resilience4j | `/java-springboot:spring-boot-resilience4j` | Resilience4j fault tolerance |
| spring-boot-saga-pattern | `/java-springboot:spring-boot-saga-pattern` | Distributed transaction Saga pattern |
| spring-boot-event-driven-patterns | `/java-springboot:spring-boot-event-driven-patterns` | Event-Driven Architecture patterns |
| spring-boot-test | `/java-springboot:spring-boot-test` | Spring Boot testing fundamentals |
| spring-boot-test-patterns | `/java-springboot:spring-boot-test-patterns` | Comprehensive testing patterns |
| spring-boot-integration | `/java-springboot:spring-boot-integration` | Spring Boot integration patterns |

### Spring Web

| Skill | Invocation | Description |
|-------|-----------|-------------|
| spring-web | `/java-springboot:spring-web` | Spring Web MVC advanced patterns |
| spring-rest | `/java-springboot:spring-rest` | Spring REST controller patterns |
| spring-webflux | `/java-springboot:spring-webflux` | Reactive programming with WebFlux |
| spring-hateoas | `/java-springboot:spring-hateoas` | HATEOAS hypermedia APIs |
| spring-graphql | `/java-springboot:spring-graphql` | GraphQL with Spring for GraphQL |
| spring-websocket | `/java-springboot:spring-websocket` | WebSocket real-time communication |
| spring-validation | `/java-springboot:spring-validation` | Bean Validation (JSR-380) |
| spring-aop | `/java-springboot:spring-aop` | Aspect-Oriented Programming |
| spring-profiles | `/java-springboot:spring-profiles` | Configuration profiles and properties |

### Spring Data

| Skill | Invocation | Description |
|-------|-----------|-------------|
| spring-data-jpa | `/java-springboot:spring-data-jpa` | Spring Data JPA with Hibernate |
| spring-data-jdbc | `/java-springboot:spring-data-jdbc` | Spring Data JDBC for simple data access |
| spring-data-redis | `/java-springboot:spring-data-redis` | Redis caching and data structures |
| spring-data-mongodb | `/java-springboot:spring-data-mongodb` | MongoDB document storage |
| spring-data-neo4j | `/java-springboot:spring-data-neo4j` | Neo4j graph database |
| spring-data-elasticsearch | `/java-springboot:spring-data-elasticsearch` | Elasticsearch search and analytics |
| spring-r2dbc | `/java-springboot:spring-r2dbc` | Reactive relational database access |

### Spring Security

| Skill | Invocation | Description |
|-------|-----------|-------------|
| spring-security | `/java-springboot:spring-security` | JWT authentication and authorization |
| spring-authorization-server | `/java-springboot:spring-authorization-server` | OAuth2 Authorization Server |
| spring-ldap | `/java-springboot:spring-ldap` | LDAP and Active Directory integration |
| spring-session | `/java-springboot:spring-session` | Distributed session management |

### Spring Cloud

| Skill | Invocation | Description |
|-------|-----------|-------------|
| spring-cloud-basics | `/java-springboot:spring-cloud-basics` | Spring Cloud microservices patterns |
| spring-cloud-config | `/java-springboot:spring-cloud-config` | Centralized configuration server |
| spring-cloud-eureka | `/java-springboot:spring-cloud-eureka` | Service discovery with Eureka |
| spring-cloud-gateway | `/java-springboot:spring-cloud-gateway` | API Gateway patterns |
| spring-cloud-openfeign | `/java-springboot:spring-cloud-openfeign` | Declarative HTTP client |
| spring-cloud-circuitbreaker | `/java-springboot:spring-cloud-circuitbreaker` | Circuit breaker resilience |
| spring-cloud-function | `/java-springboot:spring-cloud-function` | Serverless functions |

### Messaging

| Skill | Invocation | Description |
|-------|-----------|-------------|
| spring-kafka | `/java-springboot:spring-kafka` | Apache Kafka integration |
| kafka | `/java-springboot:kafka` | Kafka event streaming patterns |
| spring-amqp | `/java-springboot:spring-amqp` | RabbitMQ messaging with AMQP |
| spring-integration | `/java-springboot:spring-integration` | Enterprise Integration Patterns |
| spring-events | `/java-springboot:spring-events` | Spring Application Events |

### Infrastructure

| Skill | Invocation | Description |
|-------|-----------|-------------|
| docker | `/java-springboot:docker` | Docker containerization |
| docker-compose | `/java-springboot:docker-compose` | Docker Compose for local dev |
| spring-scheduling | `/java-springboot:spring-scheduling` | Scheduled tasks and async processing |
| spring-batch | `/java-springboot:spring-batch` | Batch processing |
| spring-retry | `/java-springboot:spring-retry` | Transparent retry with Spring Retry |
| spring-mail | `/java-springboot:spring-mail` | Email sending with JavaMail |
| spring-shell | `/java-springboot:spring-shell` | Interactive CLI applications |
| spring-statemachine | `/java-springboot:spring-statemachine` | State machine patterns |
| spring-modulith | `/java-springboot:spring-modulith` | Modular monolith architecture |

### API Documentation

| Skill | Invocation | Description |
|-------|-----------|-------------|
| openapi | `/java-springboot:openapi` | OpenAPI/Swagger specification |
| springdoc-openapi | `/java-springboot:springdoc-openapi` | Springdoc OpenAPI for Spring Boot |

### Quality & Testing

| Skill | Invocation | Description |
|-------|-----------|-------------|
| junit | `/java-springboot:junit` | JUnit 5 testing framework |
| jacoco | `/java-springboot:jacoco` | JaCoCo code coverage |
| owasp | `/java-springboot:owasp` | OWASP security guidelines |
| owasp-top-10 | `/java-springboot:owasp-top-10` | OWASP Top 10:2025 vulnerabilities |

### AI

| Skill | Invocation | Description |
|-------|-----------|-------------|
| spring-ai | `/java-springboot:spring-ai` | Spring AI for LLM integration |
| spring-ai-mcp-server-patterns | `/java-springboot:spring-ai-mcp-server-patterns` | MCP server patterns with Spring Boot |

### Architecture

| Skill | Invocation | Description |
|-------|-----------|-------------|
| hexagonal-architecture-layers-java | `/java-springboot:hexagonal-architecture-layers-java` | Hexagonal architecture layers |

## Architect Agent

The plugin includes a specialized `java-springboot-architect` agent for complex architectural work.

**Name:** `java-springboot-architect`

**Capabilities:**
- Designs microservices architectures with Spring Cloud
- Reviews Spring Boot application structure
- Recommends patterns (CRUD, Event-Driven, Saga, CQRS)
- Applies hexagonal/clean architecture principles
- Ensures security best practices (OWASP, Spring Security)
- Recommends appropriate testing strategies

**Invoke with:**
```
@java-springboot-architect design a microservices architecture for an e-commerce platform
```

## Hooks

The plugin registers a `PostToolUse` hook that silently validates Java and Spring Boot files after creation or editing. It checks:
1. Proper package structure
2. Spring Boot conventions
3. No obvious security issues

Only critical issues are reported.

## Usage Examples

### Create a new Spring Boot project

```
/java-springboot:spring-boot-project-creator
```

### Design a REST API

```
/java-springboot:spring-boot-crud-patterns
Help me implement CRUD endpoints for a Product entity
```

### Set up Kafka messaging

```
/java-springboot:spring-kafka
Add Kafka producer and consumer for order events
```

### Configure Spring Security with JWT

```
/java-springboot:spring-security
Set up JWT authentication for my REST API
```

### Add reactive support

```
/java-springboot:spring-webflux
Convert my service layer to use reactive programming
```

### Profile the application

```
/java-springboot:java-profiling
Help me analyze memory usage with JFR
```

## Flujos de desarrollo

### Flujo 1 — Proyecto nuevo desde cero

Ciclo completo desde la creación del proyecto hasta features en producción.

---

**1. Crear el proyecto base**

```
/java-springboot:new-project tienda-api
```

> El comando pregunta por stack (MVC/WebFlux), persistencia, módulos y arquitectura.
> Genera: estructura de carpetas, `pom.xml`/`build.gradle`, `application.yml` con perfiles,
> `Dockerfile` multi-stage, `docker-compose.yml` y pipeline CI.

---

**2. Diseñar la arquitectura antes de codificar** *(opcional pero recomendado)*

```
@java-springboot-architect
Necesito diseñar una API de gestión de pedidos con los dominios:
Order, Product, Customer y Payment. Usa hexagonal architecture,
JPA con PostgreSQL y autenticación JWT. Dame el mapa de bounded
contexts y en qué orden implementar cada dominio.
```

> El agente lee el proyecto recién creado y devuelve un plan de implementación
> con el árbol de dominios, orden de construcción y decisiones de diseño.

---

**3. Primer feature — basado en la HU**

```
/java-springboot:new-feature
HU-01: Como administrador quiero registrar productos con nombre,
descripción, precio y stock para gestionar el catálogo.
```

> Discovery detecta la estructura del proyecto nuevo (build file como fuente).
> Presenta el plan con árbol de archivos y espera "generar".
> Genera: `Product`, `ProductRepository`, `ProductService`,
> `ProductRequest`/`ProductResponse`, `ProductController`, tests y migración Flyway.

---

**4. Features sucesivos** *(el discovery ya encuentra código real)*

```
/java-springboot:new-feature
HU-02: Como cliente quiero listar productos con filtros por
categoría y rango de precio, paginados de 20 en 20.
```

```
/java-springboot:new-feature
HU-03: Como cliente quiero agregar productos a mi carrito
y ver el total actualizado en tiempo real.
```

> Desde el segundo feature, el discovery usa el código del primer feature
> como referencia de convenciones. El código generado es coherente con lo anterior.

---

**5. Hardening — agregar lo transversal**

```
/java-springboot:add-openapi
```
> Anota todos los controllers con `@Tag`, `@Operation`, `@ApiResponse`.
> Configura Swagger UI con autenticación JWT.

```
/java-springboot:add-docker
```
> Genera o mejora `Dockerfile` multi-stage, `docker-compose.yml`,
> `.env.example` y `Makefile` con shortcuts.

```
/java-springboot:add-resilience ProductServiceClient
```
> Agrega Circuit Breaker + Retry + Bulkhead al cliente de servicio externo.

---

**6. Revisión antes del primer commit**

```
/java-springboot:security-audit
```
> Auditoría OWASP Top 10 completa: JWT, CORS, endpoints protegidos,
> secretos en config, logging de datos sensibles.

```
/java-springboot:code-review src/main/java/com/ejemplo/product/
```
> Review estructurado: correctness, convenciones Spring Boot,
> diseño de API, acceso a datos, performance.

---

**Secuencia completa resumida**

```
/java-springboot:new-project <nombre>
@java-springboot-architect  → plan de arquitectura
/java-springboot:new-feature HU-01 → "generar"
/java-springboot:new-feature HU-02 → "generar"
/java-springboot:new-feature HU-03 → "generar"
/java-springboot:add-openapi
/java-springboot:add-docker
/java-springboot:security-audit
/java-springboot:code-review src/main/java/...
```

---

### Flujo 2 — Feature en proyecto existente

Para incorporar una nueva historia de usuario a un proyecto en curso
sin romper las convenciones ya establecidas por el equipo.

---

**1. Reconocimiento inicial** *(primera vez en el proyecto o tras tiempo fuera)*

```
@java-springboot-architect
Describe la arquitectura de este proyecto: dominios implementados,
patrones usados, convenciones de naming detectadas y dónde
encajaría mejor un nuevo dominio de "Notificaciones".
```

> El agente lee el proyecto existente y devuelve un mapa de lo que hay,
> las convenciones reales del equipo y la recomendación de dónde colocar lo nuevo.
> Usar solo si eres nuevo en el proyecto o llevas tiempo fuera.

---

**2. Generar el feature adaptado al proyecto real**

Opción A — con revisión del plan antes de generar:
```
/java-springboot:new-feature
HU-47: Como usuario quiero recibir una notificación por email
cuando mi pedido cambie de estado, con el detalle del cambio
y un enlace de seguimiento.
```
> Hace discovery del proyecto real (Bash + Glob + Read).
> Muestra plan con árbol de archivos concretos y convenciones detectadas.
> Espera "generar" antes de escribir.

Opción B — detección y generación directa, sin pausa:
```
/java-springboot:adaptive-feature
HU-47: Como usuario quiero recibir una notificación por email
cuando mi pedido cambie de estado, con el detalle del cambio
y un enlace de seguimiento.
```
> Escanea el proyecto con `find`/`cat` + Read.
> Muestra el reporte de contexto detectado (📋).
> Genera inmediatamente usando las convenciones reales del proyecto.

---

**3. Mejorar cobertura de tests si es necesario**

```
/java-springboot:add-tests NotificationService
```
> Genera tests unitarios (Mockito), slice (`@WebMvcTest`/`@DataJpaTest`)
> e integración (Testcontainers) para la clase indicada.

---

**4. Revisión antes de PR**

```
/java-springboot:code-review src/main/java/.../notification/
```
> Review enfocado en la carpeta del nuevo feature.
> Devuelve hallazgos con severidad, ubicación exacta y corrección sugerida.

```
/java-springboot:security-audit src/main/java/.../notification/
```
> Solo si el feature maneja datos sensibles, auth o integración externa.

---

**Cuándo usar `new-feature` vs `adaptive-feature`**

| Situación | Comando recomendado |
|-----------|-------------------|
| Quieres revisar el plan antes de generar | `/java-springboot:new-feature` |
| Confías en el escaneo, quieres velocidad | `/java-springboot:adaptive-feature` |
| Proyecto BFF Agent Chat Kaust Yotta | `/java-springboot:bff-new-feature` |

---

**Secuencia completa resumida**

```
@java-springboot-architect  → reconocimiento (solo si es necesario)

# Con revisión del plan:
/java-springboot:new-feature HU-47 → revisar diagnóstico → "generar"

# Sin pausa:
/java-springboot:adaptive-feature HU-47

# Post-generación:
/java-springboot:add-tests <Clase>         (si cobertura es insuficiente)
/java-springboot:code-review src/...       (antes de PR)
/java-springboot:security-audit            (si hay datos sensibles)
```

---

## Contributing

Skills are located in the `skills/` directory. Each skill follows this structure:

```
skills/<skill-name>/
├── SKILL.md          # Main skill content (required)
├── advanced.md       # Advanced patterns (optional)
├── quick-ref/        # Quick reference cards (optional)
└── references/       # Additional reference material (optional)
```

To add or modify a skill:
1. Create the skill directory under `skills/`
2. Write a `SKILL.md` with proper YAML frontmatter (`name`, `description`, `allowed-tools`)
3. Add supplementary files as needed
4. Update this README to include the new skill in the reference table

## License

MIT
