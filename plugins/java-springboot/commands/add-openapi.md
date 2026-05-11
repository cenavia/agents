---
description: Add complete OpenAPI 3.1 documentation to a Spring Boot REST API using springdoc-openapi. Annotates controllers, DTOs, and error responses. Configures Swagger UI with authentication support. Use when adding or improving API documentation.
---

Add OpenAPI documentation to: **$ARGUMENTS**

If no target is specified, scan all `@RestController` classes in the project.

## 1. Add dependency (show diff for pom.xml or build.gradle)

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.6.0</version>
</dependency>
```

## 2. Create `OpenApiConfig.java`

```java
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("<Project Name> API")
                .description("REST API documentation")
                .version("v1.0.0")
                .contact(new Contact().name("Team").email("team@example.com"))
                .license(new License().name("MIT")))
            .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
            .components(new Components()
                .addSecuritySchemes("bearerAuth",
                    new SecurityScheme()
                        .type(HTTP).scheme("bearer").bearerFormat("JWT")
                        .description("JWT token — obtain via POST /api/v1/auth/login")));
    }
}
```

## 3. Add `application.yml` configuration

```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    try-it-out-enabled: true
    operations-sorter: method
    tags-sorter: alpha
    display-request-duration: true
  show-actuator: false
  default-produces-media-type: application/json
```

## 4. Annotate each `@RestController`

For every controller found, add:

```java
@Tag(name = "<Resource>", description = "<Resource> management operations")
@RestController
public class <Resource>Controller {

    @Operation(
        summary = "Get all <resources>",
        description = "Returns paginated list of <resources>",
        responses = {
            @ApiResponse(responseCode = "200", description = "Successful retrieval",
                content = @Content(schema = @Schema(implementation = <Resource>Response.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized",
                content = @Content(schema = @Schema(implementation = ProblemDetail.class)))
        }
    )
    @GetMapping
    public ResponseEntity<Page<<Resource>Response>> findAll(...) { ... }

    @Operation(summary = "Get <resource> by ID")
    @ApiResponse(responseCode = "404", description = "Not found",
        content = @Content(schema = @Schema(implementation = ProblemDetail.class)))
    @GetMapping("/{id}")
    public ResponseEntity<<Resource>Response> findById(...) { ... }

    // POST: @ApiResponse 201 Created
    // PUT: @ApiResponse 200 OK, 404 Not Found
    // DELETE: @ApiResponse 204 No Content, 404 Not Found
}
```

## 5. Annotate DTO records / classes

```java
@Schema(description = "Request body for creating a <Resource>")
public record <Resource>Request(
    @Schema(description = "Name of the resource", example = "My Resource")
    @NotBlank String name,

    @Schema(description = "Optional description", example = "A detailed description")
    String description
) {}
```

## 6. Document global error responses

Create `GlobalExceptionHandlerDoc.java` or add to existing `@ControllerAdvice`:
- Document `400 Bad Request` → validation errors format
- Document `404 Not Found` → `ProblemDetail` schema
- Document `409 Conflict` → duplicate resource
- Document `500 Internal Server Error`

## 7. Verify

After applying all annotations, show:
- Swagger UI URL: `http://localhost:<port>/swagger-ui.html`
- API docs JSON: `http://localhost:<port>/v3/api-docs`
- List of all documented endpoints with their operation IDs
