---
description: Genera un feature Spring Boot adaptado al 100% a las convenciones reales del proyecto. Escanea el proyecto, detecta arquitectura, naming, stack y patrones de test, reporta el contexto detectado, y genera el código inmediatamente. El código generado es indistinguible del escrito por el mismo equipo. Usar cuando se necesite máxima fidelidad a las convenciones del proyecto.
---

Genera un feature Spring Boot para: **$ARGUMENTS**

> **Protocolo:** escanear → detectar → reportar contexto → generar sin pausas.
> Los pasos 1–4 se ejecutan siempre y en su totalidad antes de escribir una línea de código.
> Si una detección es ambigua, preguntar solo eso puntualmente y continuar.

---

## Paso 1 — Escanear el proyecto

Ejecutar con **Bash**:

```bash
# Árbol de directorios (profundidad 4, excluir ruido)
find . -maxdepth 4 -type d \
  | grep -v -E "\.git|target|build|\.gradle|node_modules|\.idea|out" \
  | sort

# Build file completo
cat pom.xml 2>/dev/null || cat build.gradle 2>/dev/null || cat build.gradle.kts 2>/dev/null

# Archivos fuente Java — excluir tests, primeros 30
find src/main/java -name "*.java" | sort | head -30

# Archivos de test — primeros 15
find src/test/java -name "*.java" | sort | head -15

# Migraciones existentes
find src/main/resources -name "*.sql" -path "*/migration/*" \
  -o -name "*.xml" -path "*/changelog/*" 2>/dev/null | sort
```

Anotar:
- Paquete raíz (desde `*Application.java`)
- Carpetas de primer nivel bajo el paquete raíz
- Dominio con más archivos (será la referencia)
- Stack del build file: Spring Boot version, Java version, dependencias clave
- Herramienta de migración y versión más alta existente

---

## Paso 2 — Detectar el patrón de arquitectura

Aplicar en orden — primera coincidencia gana:

```
SI carpetas "domain/" + "infrastructure/" + ("application/" o "adapter/")
  → Hexagonal / Ports and Adapters

SI carpetas "domain/" + "service/" + "repository/" al mismo nivel
  → Layered con naming DDD

SI módulos organizados por feature/dominio primero, con subcarpetas por capa dentro
  → DDD modular

SI carpetas "controller/" + "service/" + "repository/" + "entity/" al mismo nivel
  → Capas tradicionales (MVC)

SI ninguna coincide
  → Leer 3 archivos y derivar manualmente
```

---

## Paso 3 — Leer un archivo por capa del feature de referencia

Usando **Read**, leer del dominio más desarrollado:

| Capa | Extraer |
|------|---------|
| Entidad / modelo | anotaciones de persistencia, estilo (`record` / `@Data @Builder` / clase), clase base si hereda |
| Repositorio / puerto | interfaz extendida, prefijo/sufijo del nombre, métodos con `@Query` |
| Servicio / caso de uso | ¿interfaz separada?, prefijo `I`, sufijo `UseCase`/`Service`, carpeta de impl, `@Transactional` |
| Controller | `ResponseEntity<T>` o retorno directo, `@Validated`/`@Valid`, status codes, ruta base, OpenAPI |
| DTO | `record` o Lombok, ubicación, sufijos (`Request`/`Response`, `Dto`, `Command`) |
| Mapper | MapStruct / manual inline / ninguno, ubicación |
| Test de servicio | `@ExtendWith(MockitoExtension)` o `@SpringBootTest`, mocks, librería de assertions |
| Test de controller | `@WebMvcTest` / `@WebFluxTest`, mock de auth, clase base si existe |
| Shared | excepción de dominio exacta, `@ControllerAdvice` y formato de error |

---

## Paso 4 — Completar el stack

Del build file ya leído, registrar:

| Elemento | Valor detectado |
|----------|----------------|
| Java | |
| Spring Boot | |
| Capa web | MVC / WebFlux |
| Persistencia | JPA / MongoDB / JDBC / R2DBC |
| MapStruct | presente / ausente |
| Flyway / Liquibase | presente / ausente |
| springdoc-openapi | presente / ausente |
| Spring Security | presente / ausente |
| Testcontainers | presente / ausente |

---

## Paso 5 — Reportar el contexto y generar

Mostrar el reporte y a continuación generar los archivos directamente, sin esperar confirmación.

```
📋 Contexto detectado del proyecto
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Arquitectura:      [patrón + criterio que lo determinó]
Paquete raíz:      [valor real]
Java / Spring Boot:[versión real]
Capa web:          [MVC / WebFlux]
Persistencia:      [tipo real]
Migración:         [Flyway vX / Liquibase / ninguna]

Modelo de dominio: [record / @Data @Builder / clase plana]
Repositorio:       [nombre real — interfaz extendida]
Servicio:          [interfaz I<Name>UseCase + impl / solo @Service]
DTO location:      [ruta real]
Mapper:            [MapStruct en <ruta> / manual inline / ninguno]
Excepción base:    [nombre exacto]
Test servicio:     [@ExtendWith(MockitoExtension) / @SpringBootTest]
Test controller:   [@WebMvcTest / @WebFluxTest]
Base class test:   [nombre / ninguna]
Assertions:        [AssertJ / Hamcrest / JUnit]
Ruta base API:     [valor real]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: [nombre del feature]

Archivos a generar:
  [ruta/real/NombreReal1.java]
  [ruta/real/NombreReal2.java]
  ...
  [src/main/resources/db/migration/V<n+1>__...sql]  ← si Flyway

Desviaciones del proyecto vs defaults Spring Boot:
  [solo si existe algo inusual — con archivo de referencia]
  o "Ninguna"

Conflictos:
  [archivo que ya existe + opciones A/B/C + propuesta]
  o "Sin conflictos"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Generando...
```

---

## Generación

Generar en este orden. Ruta completa como header antes de cada bloque de código.

### Orden

1. Entidad / modelo de dominio
2. Puerto de salida / repositorio
3. Interfaz del caso de uso (si el proyecto usa interfaces)
4. Implementación del caso de uso / servicio
5. DTOs: Request, Response
6. Mapper (solo si MapStruct está en el build file)
7. Adaptador de persistencia (si arquitectura hexagonal)
8. Controller
9. Script de migración (solo si Flyway/Liquibase presentes)
10. Test del servicio / caso de uso
11. Test del controller
12. Test de repositorio (solo si el proyecto tiene tests de este tipo)

### Reglas — no negociables

**Paquetes y carpetas:** exactamente los detectados. Ni un segmento diferente.

**Modelo:** el estilo exacto del proyecto. Si usa `record`, usar `record`. Si usa `@Data @Builder`, usar eso. Si extiende `BaseEntity`, extenderla — no redeclarar `id`, `createdAt`, `updatedAt`.

**Servicio:** si el proyecto no tiene interfaz de servicio, no crearla. Si tiene prefijo `I`, usarlo. La carpeta de implementación es la detectada (`usecases/`, `usecase/`, `impl/`, etc.).

**Controller:** `ResponseEntity<T>` si el proyecto lo usa. Devolución directa si no. Status codes: los mismos que el proyecto ya utiliza. OpenAPI solo si `springdoc` está en el build file y los controllers existentes ya lo usan.

**Repositorio:** prefijo/sufijo exacto detectado. Extensión de interfaz exacta detectada.

**Mapper:** si el proyecto mapea inline en el servicio, hacerlo así. No introducir MapStruct si no estaba.

**Tests:** extender la clase base si existe. Mock de auth: el mecanismo exacto detectado. Assertions: la librería detectada. `StepVerifier` solo si el proyecto es reactivo. No generar tests de un tipo que el proyecto no tiene, salvo que el usuario los pida.

**Lo que nunca ocurre:**
- Sugerir "sería mejor usar X" si el proyecto ya usa Y
- Generar con un patrón distinto al detectado
- Asumir dependencias que no están en el build file
- Crear mapper si el proyecto mapea inline
- Usar Lombok si no está declarado

### Checklist pre-entrega

Verificar antes de mostrar el output:

- [ ] Paquetes coinciden carácter a carácter con los detectados
- [ ] Ningún import referencia una clase que no exista en el proyecto
- [ ] Estilo de modelo consistente con el proyecto
- [ ] Controller sigue el patrón de retorno detectado
- [ ] Tests usan la librería de assertions detectada y extienden la clase base si existe
- [ ] Script de migración con el número de versión correcto
- [ ] Sin dependencias nuevas no declaradas en el build file

---

## Checklist de integración post-generación

Al final del output, mostrar:

```
✅ Para conectar el feature
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
□ [si hay dependencias nuevas]
    Agregar a pom.xml / build.gradle:
    <bloque exacto>

□ [si rutas necesitan configuración de seguridad]
    Registrar en SecurityConfig:
    .requestMatchers("/ruta/**").<regla>()

□ [si Flyway] Ejecutar migración:
    ./mvnw flyway:migrate   o   ./gradlew flywayMigrate

□ Compilar y ejecutar tests:
    ./mvnw test   o   ./gradlew test

□ [si springdoc presente] Verificar en Swagger UI:
    http://localhost:<puerto>/swagger-ui.html
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
