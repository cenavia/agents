# Review Angular Code

Perform a focused Angular code review on the specified file or feature.

## Target

File, folder, or paste of code to review: $ARGUMENTS

## Steps to follow

1. **Read the target**: open and read all relevant files (component, template, service, spec).

2. **Check correctness**:
   - Signals read inside reactive contexts only
   - No mutation of signal values without `update()` or `set()`
   - Subscriptions cleaned up with `takeUntilDestroyed()` or `DestroyRef`
   - `ChangeDetectionStrategy.OnPush` used where applicable

3. **Check performance**:
   - `@for` blocks have `track` expressions
   - No heavy logic in template expressions — should be `computed()`
   - Routes are lazy-loaded where appropriate
   - `@defer` used for below-the-fold content

4. **Check security**:
   - No `[innerHTML]` without sanitization
   - No `bypassSecurityTrust*` unless absolutely necessary (flag as critical)
   - HTTP errors are handled

5. **Check accessibility**:
   - Interactive elements have ARIA labels or roles
   - Keyboard events handled alongside click events
   - Images have `alt` attributes

6. **Check modern patterns**:
   - `inject()` used instead of constructor injection (v14+)
   - Standalone components (v15+)
   - Signal inputs/outputs (v17+)

7. **Output format**:

   Group by severity: **Critical** | **Warning** | **Suggestion**

   Each item:
   - File and approximate line
   - What the issue is
   - Why it matters
   - Recommended fix (show code snippet)

   End with: **Verdict** — Approve / Approve with suggestions / Request changes
