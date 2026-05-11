---
description: Create a new Spring Boot 3.x project from scratch. Generates project structure, pom.xml/build.gradle, base configuration, Docker setup, and initial CI pipeline. Use when starting a new Spring Boot application.
---

Create a new Spring Boot project with these specifications: **$ARGUMENTS**

## 1. Gather requirements (ask if not provided)
- Project name, group ID, artifact ID
- Spring Boot version: 3.4.x (default) or 4.x
- Build tool: Maven (default) or Gradle (Kotlin DSL)
- Java version: 21 (default) or 17
- Modules needed (select from list):
  - Web (Spring Web MVC)
  - Security (Spring Security + JWT)
  - Data JPA + chosen database (PostgreSQL/MySQL/H2)
  - Actuator
  - Validation
  - Docker + Docker Compose
  - OpenAPI (springdoc)
  - Kafka
  - Cloud (Eureka/Config/Gateway)
- Architecture style: Layered (default) or Hexagonal

## 2. Generate project structure

```
<artifact-id>/
├── src/
│   ├── main/
│   │   ├── java/<group-path>/
│   │   │   ├── <ArtifactId>Application.java
│   │   │   ├── config/          (SecurityConfig, OpenApiConfig, etc.)
│   │   │   ├── domain/
│   │   │   ├── application/
│   │   │   ├── adapter/
│   │   │   └── infrastructure/
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       └── db/migration/    (if JPA)
│   └── test/
│       └── java/<group-path>/
│           └── <ArtifactId>ApplicationTests.java
├── docker/
│   └── Dockerfile
├── docker-compose.yml
├── docker-compose.dev.yml
├── .github/
│   └── workflows/
│       └── ci.yml
├── .gitignore
├── .editorconfig
└── pom.xml (or build.gradle.kts)
```

## 3. Required file contents

### pom.xml / build.gradle.kts
- Parent: `spring-boot-starter-parent` at chosen version
- Dependencies matching selected modules
- Plugins: `spring-boot-maven-plugin` or equivalent, `jacoco`, `surefire`/`failsafe`

### application.yml
- Profiles: `dev`, `prod`
- Actuator endpoints, datasource placeholders `${DB_URL}`, logging level

### Dockerfile
- Multi-stage: `eclipse-temurin:21-jdk-alpine` build → `eclipse-temurin:21-jre-alpine` runtime
- Non-root user, health check, `ENTRYPOINT`

### docker-compose.yml
- App service + database service (if selected) + any broker (Kafka/Zookeeper if selected)
- Named volumes, `.env` file reference

### .github/workflows/ci.yml
- Trigger: push to `main`, PRs
- Steps: checkout, setup Java, cache Maven/Gradle, test, build, optional Docker build

### SecurityConfig.java (if security selected)
- JWT filter chain, public/private route configuration
- `BCryptPasswordEncoder` bean

### OpenApiConfig.java (if openapi selected)
- `OpenAPI` bean with info, security scheme

## 4. After generating files
Show a summary table:

| File | Purpose |
|------|---------|
| ... | ... |

Then show the Maven/Gradle command to run locally and how to start with Docker Compose.
