---
description: Generate comprehensive tests for a Spring Boot class or feature. Covers unit tests with Mockito, slice tests (@WebMvcTest, @DataJpaTest), integration tests with Testcontainers, and contract tests. Use when adding or improving test coverage.
---

Generate comprehensive tests for: **$ARGUMENTS**

If no target is specified, read the current file or ask which class/feature to test.

## 1. Identify what to test
- Read the target class(es) to understand dependencies, methods, and contracts
- Determine existing test coverage if tests already exist
- Identify the test layers needed:
  - Unit tests (service, mapper, validator logic)
  - Slice tests (controller, repository)
  - Integration tests (full flow)

## 2. Unit Tests — `*Test.java`

For **Service classes**:
```java
@ExtendWith(MockitoExtension.class)
class <Class>Test {
    @Mock <Dep> dep;
    @InjectMocks <Class> service;

    // happy path, edge cases, exception paths
}
```
- One test method per behavior, not per method
- Use `@ParameterizedTest` with `@MethodSource` for boundary values
- Assert exceptions with `assertThrows` + message verification
- Verify interactions: `verify(mock).method(captor.capture())`

## 3. Controller Slice Tests — `@WebMvcTest`
```java
@WebMvcTest(<Controller>.class)
class <Controller>Test {
    @Autowired MockMvc mockMvc;
    @MockBean <Service> service;

    // GET, POST, PUT, DELETE — success + validation errors + not found
}
```
- Use `MockMvcRequestBuilders` + `MockMvcResultMatchers`
- Test all `@Valid` constraint violations → 400 response
- Test 404 / 409 / 500 error scenarios
- Verify JSON response body with `jsonPath`

## 4. Repository Slice Tests — `@DataJpaTest`
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = NONE)
@Testcontainers
class <Repository>Test {
    @Container static PostgreSQLContainer<?> pg = new PostgreSQLContainer<>("postgres:16");
    @Autowired <Repository> repo;

    // CRUD operations, custom queries, pagination
}
```

## 5. Integration Tests — `@SpringBootTest`
```java
@SpringBootTest(webEnvironment = RANDOM_PORT)
@Testcontainers
class <Feature>IntegrationTest {
    @Container static PostgreSQLContainer<?> pg = ...;
    @Autowired TestRestTemplate restTemplate;

    // End-to-end happy path through HTTP → DB → response
}
```

## 6. Test data strategy
- Use `@Sql` scripts or test fixtures for repeatable data
- Builder pattern or factory methods for test objects
- Use `@DirtiesContext` only when truly needed

## 7. Coverage targets
After generating tests, show:
- Estimated branch coverage per class
- Which edge cases are still untested (known gaps)
- Command to run with coverage: `./mvnw test jacoco:report`
