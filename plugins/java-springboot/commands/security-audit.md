---
description: Audit Spring Boot code for security vulnerabilities following OWASP Top 10 and Spring Security best practices. Checks authentication, authorization, injection risks, secret exposure, dependency vulnerabilities, and data protection. Use when reviewing security posture of a Spring Boot application.
---

Perform a security audit on: **$ARGUMENTS**

If no target is specified, audit the entire project starting from `src/main/java`.

## Audit checklist — scan each category and report findings

### A01 — Broken Access Control
- [ ] All endpoints protected with `@PreAuthorize` or `SecurityFilterChain` rules
- [ ] No missing `@Secured` / `@RolesAllowed` on sensitive operations
- [ ] IDOR risk: IDs validated against authenticated user's ownership
- [ ] CORS configuration: no wildcard `*` origins in production config
- [ ] Actuator endpoints not exposed without authentication (`/actuator/**`)

### A02 — Cryptographic Failures
- [ ] Passwords hashed with `BCryptPasswordEncoder` (never MD5/SHA1)
- [ ] JWT secrets are long (≥256 bits), stored as env var, not hardcoded
- [ ] Sensitive fields not logged (`@JsonProperty(access = WRITE_ONLY)` on passwords)
- [ ] TLS enforced for external connections (datasource, kafka, redis URLs)
- [ ] No plain HTTP in `application.yml` URLs for production profile

### A03 — Injection
- [ ] No native SQL with string concatenation → use `@Query` with `:param` or JPA Criteria
- [ ] JPQL queries parameterized, not built with `+` operator
- [ ] `@RequestParam` / path variables validated with Bean Validation before use
- [ ] File upload: content-type validation, size limits, no path traversal
- [ ] Log injection: user input not interpolated directly into log messages

### A05 — Security Misconfiguration
- [ ] `application-prod.yml` does not contain hardcoded credentials
- [ ] `DEBUG` logging not enabled in production profile
- [ ] Spring Boot DevTools not on classpath in production
- [ ] Default error messages don't expose stack traces (`server.error.include-stacktrace=never`)
- [ ] H2 console disabled in production

### A06 — Vulnerable Components
- [ ] Check `pom.xml` / `build.gradle` for known CVEs (flag dependencies older than 6 months)
- [ ] `spring-boot-starter-parent` version is ≥ 3.3.x
- [ ] No `jackson-databind` < 2.14, no `log4j-core` < 2.17.1

### A07 — Authentication Failures
- [ ] JWT `exp` claim validated on every request
- [ ] JWT algorithm explicitly set (`RS256` or `HS256`), never `none`
- [ ] Refresh token rotation implemented (old token invalidated on use)
- [ ] Failed login attempts rate-limited or locked after N failures
- [ ] Password reset flow uses time-limited, single-use token

### A08 — Software and Data Integrity
- [ ] Dependency checksums verified (Maven `--strict-checksums`)
- [ ] CI pipeline does not accept untrusted plugins
- [ ] Deserialization: `@JsonTypeInfo` usage reviewed for polymorphic types

### A09 — Logging & Monitoring Failures
- [ ] Authentication events logged: success, failure, logout
- [ ] `AuthenticationAuditListener` or equivalent configured
- [ ] Sensitive data (passwords, tokens, PII) absent from logs
- [ ] Structured JSON logging configured for production

### A10 — SSRF
- [ ] Outbound HTTP calls (`RestClient`, `WebClient`, `OpenFeign`) use allowlist of hosts
- [ ] User-supplied URLs never passed directly to HTTP clients

## Output format

For each finding:
```
[SEVERITY: CRITICAL|HIGH|MEDIUM|LOW] Category — Description
  File: src/main/java/.../File.java:line
  Issue: what is wrong
  Fix: concrete code correction
```

End with a **Risk Summary table**:
| Severity | Count |
|----------|-------|
| CRITICAL | N     |
| HIGH     | N     |
| MEDIUM   | N     |
| LOW      | N     |

Then list the top 3 priority fixes to address first.
