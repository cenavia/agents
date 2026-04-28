# Fix Angular Build

Diagnose and fix Angular build or compilation errors.

## Context

Error or issue to fix: $ARGUMENTS

## Steps to follow

1. **Run the build** to capture the full error output:
   ```bash
   npx ng build 2>&1
   ```
   If the user already pasted errors, skip this and work from what's provided.

2. **Categorize the errors**:
   - **TS type errors**: missing types, incorrect generics, strict null checks
   - **Template errors**: unknown properties, missing imports, type mismatches in bindings
   - **DI errors**: missing providers, circular dependencies
   - **Module/import errors**: missing `imports` array in standalone component, wrong path
   - **Signal errors**: reading signal without calling it `()`, writing to read-only `input()`

3. **Fix each error**:
   - For each error, open the file, understand the root cause, and apply the minimal fix.
   - Do NOT suppress errors with `// @ts-ignore` or `any` casts unless no alternative exists.

4. **Re-run build** after fixes:
   ```bash
   npx ng build 2>&1
   ```

5. If new errors surface, repeat from step 2.

6. Report: root cause of each error and the fix applied. Flag any patterns that suggest a structural problem worth addressing separately.
