---
description: Add Docker and Docker Compose support to a Spring Boot project. Generates optimized multi-stage Dockerfile, docker-compose.yml for local dev, and docker-compose.prod.yml for production. Use when containerizing a Spring Boot application.
---

Add Docker support to the Spring Boot project: **$ARGUMENTS**

Read the `pom.xml` or `build.gradle` and `application.yml` to detect: Java version, app name, port, and external services (databases, brokers, caches).

## 1. Generate `Dockerfile`

Multi-stage build optimized for Spring Boot:

```dockerfile
# Stage 1: Build
FROM eclipse-temurin:<java-version>-jdk-alpine AS builder
WORKDIR /app
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline -q
COPY src ./src
RUN ./mvnw package -DskipTests -q

# Stage 2: Extract layers (Spring Boot layertools)
FROM eclipse-temurin:<java-version>-jre-alpine AS layers
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# Stage 3: Runtime
FROM eclipse-temurin:<java-version>-jre-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=layers /app/dependencies/ ./
COPY --from=layers /app/spring-boot-loader/ ./
COPY --from=layers /app/snapshot-dependencies/ ./
COPY --from=layers /app/application/ ./
USER appuser
EXPOSE <port>
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD wget -qO- http://localhost:<port>/actuator/health || exit 1
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
```

## 2. Generate `docker-compose.yml` (local development)

Include services detected from the project:
- `app` service: build from `Dockerfile`, env vars from `.env`, depends_on all infra services
- `db` service: PostgreSQL/MySQL/MongoDB with named volume and healthcheck
- `cache` service: Redis (if spring-data-redis detected)
- `broker` service: Kafka + Zookeeper (if spring-kafka detected), or RabbitMQ (if spring-amqp)
- `mail` service: Mailhog (if spring-mail detected)

```yaml
version: '3.9'
services:
  app:
    build: .
    ports: ["<port>:<port>"]
    environment:
      SPRING_PROFILES_ACTIVE: dev
      DB_URL: jdbc:postgresql://db:5432/${DB_NAME}
      DB_USERNAME: ${DB_USERNAME}
      DB_PASSWORD: ${DB_PASSWORD}
    depends_on:
      db:
        condition: service_healthy
    networks: [app-network]

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes: [postgres-data:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USERNAME}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks: [app-network]

volumes:
  postgres-data:
networks:
  app-network:
    driver: bridge
```

## 3. Generate `.env.example`
Template with all environment variables used in compose (no real values):
```
DB_NAME=appdb
DB_USERNAME=appuser
DB_PASSWORD=
SPRING_PROFILES_ACTIVE=dev
JWT_SECRET=
```

## 4. Generate `.dockerignore`
```
target/
.git/
*.md
.mvn/wrapper/maven-wrapper.jar
```

## 5. Add Makefile shortcuts
```makefile
.PHONY: build up down logs restart

build:
	docker compose build --no-cache

up:
	docker compose up -d

down:
	docker compose down -v

logs:
	docker compose logs -f app

restart:
	docker compose restart app
```

## 6. Update `application-dev.yml` / `application-prod.yml`
Add datasource and service URLs using environment variable placeholders matching the compose file.

## After generating
Show the commands to:
1. Build and start: `make up` or `docker compose up --build`
2. Check health: `curl http://localhost:<port>/actuator/health`
3. View logs: `docker compose logs -f app`
