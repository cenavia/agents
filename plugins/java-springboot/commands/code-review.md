---
description: Review Java or Spring Boot code for correctness, design quality, performance, and best practices. Produces structured feedback with severity levels and suggested fixes. Use when reviewing PRs, auditing existing code, or validating implementations.
---

Review the following code: **$ARGUMENTS**

If no target is specified, review the most recently modified Java file or ask which file/PR to review.

## Review dimensions

Evaluate each dimension and report only real issues — skip dimensions with no findings.

---

### 1. Correctness
- Logic errors, wrong conditionals, off-by-one
- Null pointer risks: missing null checks, `Optional` misuse
- Transaction boundaries: `@Transactional` missing on write operations, or applied at wrong layer
- Exception handling: swallowed exceptions, wrong exception types, missing rollback triggers
- Concurrency: shared mutable state without synchronization, `@Async` + `@Transactional` pitfalls

### 2. Spring Boot conventions
- Constructor injection (not field injection with `@Autowired`)
- Service layer does not call other services' controllers — only ports/interfaces
- `@RestController` never contains business logic — delegates to service
- Repository never accessed directly from controller
- `@Component`/`@Service`/`@Repository` applied to correct layer types
- `@ConfigurationProperties` used for multi-field config (not multiple `@Value`)

### 3. API design (REST controllers)
- HTTP method semantics correct (GET idempotent, POST creates, PUT replaces, PATCH partial)
- Status codes appropriate (201 for create, 204 for delete, 409 for conflict)
- `ResponseEntity` used consistently — not mixed with direct return types
- Pagination: collection endpoints use `Page<T>` not `List<T>`
- Error responses use problem detail format (RFC 7807) or consistent structure

### 4. Data access
- N+1 query risk: `@OneToMany` without `fetch = LAZY` or missing `@EntityGraph`
- No `findAll()` on unbounded tables — always paginate
- Transactions: read-only queries use `@Transactional(readOnly = true)`
- DTO projection used for read-only queries (not full entity graphs)
- Cascade types reviewed — no `CascadeType.ALL` on `@ManyToMany`

### 5. Code quality
- Methods > 30 lines: flag as extract-method candidate
- Cyclomatic complexity > 5: flag for simplification
- Magic numbers/strings: should be constants or config values
- Duplicated logic: extract to shared utility or base class
- Naming: verbs for methods, nouns for classes, no abbreviations

### 6. Performance signals
- Synchronous blocking calls inside `@Async` methods
- Missing `@Cacheable` on expensive, frequently-called read operations
- Unnecessary eager loading of large associations
- `String` concatenation in loops → `StringBuilder`
- Large object instantiation inside hot paths

### 7. Test quality (if tests are included)
- Tests assert behavior, not implementation details
- No `Thread.sleep()` in tests — use `Awaitility`
- Each test has a single logical assertion or a coherent group
- Test names describe the scenario: `should_return404_when_userNotFound`

---

## Output format

Group findings by dimension. For each issue:

```
[HIGH|MEDIUM|LOW] Brief title
  Line: <file>:<line>
  Problem: clear explanation of what is wrong
  Fix:
  ```java
  // corrected code snippet
  ```
```

End with a **Summary**:
- Total issues by severity
- The single most important change to make first
- Overall assessment: ✅ Ready to merge | ⚠️ Minor changes needed | ❌ Significant issues
