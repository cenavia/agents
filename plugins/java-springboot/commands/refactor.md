---
description: Refactor Java or Spring Boot code for clarity, maintainability, and adherence to clean code principles. Applies extract method, remove parameter, introduce value object, decompose conditional, and other catalog refactorings. Use when improving code quality without changing behavior.
---

Refactor the following code: **$ARGUMENTS**

If no target is specified, read the current file or ask which class to refactor.

## Ground rules
- Behavior must not change — every refactoring must be semantically equivalent
- Run tests mentally (or actually if available) after each transformation
- Prefer small, named, reversible steps over big-bang rewrites
- Only refactor what is genuinely problematic — do not gold-plate

## 1. Analyze the code

Read the target and identify:
- Methods > 20 lines → Extract Method candidates
- Parameters > 3 on a method → Introduce Parameter Object
- Repeated conditional patterns → Extract to named predicate or strategy
- Primitive obsession (raw String/int for domain concepts) → Value Object
- Data classes with behavior → move behavior to where data lives
- God classes (> 300 lines, > 10 fields) → Split Responsibility

## 2. Apply refactorings in this priority order

### Extract Method
When a block of code can be named:
```java
// Before
if (user.getAge() >= 18 && user.getCountry().equals("US") && !user.isBanned()) { ... }

// After
if (isEligibleForService(user)) { ... }

private boolean isEligibleForService(User user) {
    return user.getAge() >= 18 && user.getCountry().equals("US") && !user.isBanned();
}
```

### Introduce Value Object
When primitives represent domain concepts:
```java
// Before: String email, String phone passed around
// After:
public record Email(String value) {
    public Email { Objects.requireNonNull(value); if (!value.contains("@")) throw new IllegalArgumentException(); }
}
```

### Replace Conditional with Polymorphism
When switch/if-else branches vary by type:
```java
// Before: switch (type) { case "PDF": ... case "CSV": ... }
// After: interface ReportExporter { void export(Report r); }
//        PdfReportExporter, CsvReportExporter implement it
```

### Decompose Conditional
When complex boolean logic is hard to read:
```java
// Before: if (a && b || c && !d) { ... }
// After:
boolean isPrimary = a && b;
boolean isFallback = c && !d;
if (isPrimary || isFallback) { ... }
```

### Remove Flag Parameters
When booleans control behavior inside a method:
```java
// Before: process(item, true)  // what does true mean?
// After: processForExport(item) vs processForDisplay(item)
```

### Move Method
When a method uses more data from another class than its own:
```java
// Move orderTotal() from Order to OrderLine if it iterates lines
```

### Simplify Spring-specific patterns
- Replace field injection with constructor injection
- Replace multiple `@Value` with `@ConfigurationProperties` record
- Extract inline `new` object construction to factory method
- Replace `Optional.get()` with `.orElseThrow()`

## 3. Output format

For each refactoring applied:
```
### Refactoring: <Name> — <File>:<lines>
**Why**: <one sentence on the problem>
**Before**:
```java
// original code
```
**After**:
```java
// refactored code
```
**Risk**: None | Low (logic unchanged) | Medium (verify with test X)
```

End with:
- Total refactorings applied (count by type)
- Which tests to run to verify behavior unchanged
- Any follow-up refactorings deferred and why
