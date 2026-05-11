---
description: Add fault tolerance patterns to Spring Boot services using Resilience4j. Configures Circuit Breaker, Retry, Rate Limiter, Bulkhead, and TimeLimiter for HTTP clients, service calls, and external integrations. Use when hardening Spring Boot applications against cascading failures.
---

Add resilience patterns to: **$ARGUMENTS**

Read the target class or describe the integration point (e.g. "Feign client to PaymentService", "RestClient call to external API").

## 1. Add dependencies

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
</dependency>
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

## 2. Configuration in `application.yml`

Generate config tuned to the detected integration type:

```yaml
resilience4j:
  circuitbreaker:
    instances:
      <service-name>:
        sliding-window-size: 10
        failure-rate-threshold: 50          # % failures to open circuit
        wait-duration-in-open-state: 10s
        permitted-calls-in-half-open-state: 3
        slow-call-duration-threshold: 2s
        slow-call-rate-threshold: 80
        record-exceptions:
          - java.io.IOException
          - java.util.concurrent.TimeoutException
          - feign.FeignException.ServiceUnavailable
        ignore-exceptions:
          - com.example.app.exception.BusinessException

  retry:
    instances:
      <service-name>:
        max-attempts: 3
        wait-duration: 500ms
        exponential-backoff-multiplier: 2
        retry-exceptions:
          - java.io.IOException
          - java.util.concurrent.TimeoutException

  ratelimiter:
    instances:
      <service-name>:
        limit-for-period: 100
        limit-refresh-period: 1s
        timeout-duration: 0

  bulkhead:
    instances:
      <service-name>:
        max-concurrent-calls: 20
        max-wait-duration: 100ms

  timelimiter:
    instances:
      <service-name>:
        timeout-duration: 3s
        cancel-running-future: true
```

## 3. Annotate the service method

Apply patterns in the correct order (outermost → innermost):

```java
@Service
@RequiredArgsConstructor
public class <Service>Client {

    private static final Logger log = LoggerFactory.getLogger(<Service>Client.class);

    @CircuitBreaker(name = "<service-name>", fallbackMethod = "fallback<Method>")
    @Retry(name = "<service-name>")
    @Bulkhead(name = "<service-name>", type = Bulkhead.Type.SEMAPHORE)
    @TimeLimiter(name = "<service-name>")
    public CompletableFuture<<ReturnType>> call<Method>(<Params>) {
        // actual integration call
    }

    // Fallback receives the exception as last parameter
    public CompletableFuture<<ReturnType>> fallback<Method>(<Params>, Throwable ex) {
        log.warn("Fallback triggered for <service-name>: {}", ex.getMessage());
        // return safe default or throw domain exception
    }
}
```

## 4. Expose metrics via Actuator

Add to `application.yml`:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,circuitbreakers,retries
  health:
    circuitbreakers:
      enabled: true
  endpoint:
    health:
      show-details: always
```

Check at: `GET /actuator/health` → shows circuit state per instance

## 5. Add unit tests for resilience behavior

```java
@ExtendWith(MockitoExtension.class)
class <Service>ClientTest {

    @Test
    void should_open_circuit_after_threshold_failures() {
        // configure mock to throw, call N times, assert CircuitBreakerOpenException
    }

    @Test
    void should_call_fallback_when_circuit_open() { ... }

    @Test
    void should_retry_on_transient_failure() { ... }
}
```

## After applying

Show:
- The circuit breaker state endpoint: `GET /actuator/circuitbreakers`
- Metrics: `GET /actuator/metrics/resilience4j.circuitbreaker.calls`
- Summary table of which patterns were applied to which methods and why
