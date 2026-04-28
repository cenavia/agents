# Add Angular Tests

Generate comprehensive tests for an Angular component or service.

## Target

File or feature to test: $ARGUMENTS

## Steps to follow

1. **Read the target file(s)** to understand inputs, outputs, injected dependencies, and public API.

2. **Identify the testing needs**:
   - Inputs and their effects on the template
   - Outputs / event emissions
   - Signal state transitions
   - Service method return values and error paths
   - Route guard or resolver logic (if applicable)

3. **Scaffold the test file** next to the source file with the `.spec.ts` suffix.

4. **TestBed setup**:
   ```ts
   TestBed.configureTestingModule({
     imports: [ComponentUnderTest],
     providers: [
       { provide: SomeDep, useValue: mockDep }
     ]
   });
   ```

5. **Cover these cases** (skip only if genuinely not applicable):
   - Default render (snapshot-style assertion on key DOM elements)
   - Each `@Input()` with a meaningful value
   - Each `@Output()` — verify emission on user action
   - Error state (if service can fail)
   - Signal updates: call `TestBed.flushEffects()` before asserting

6. **For services**: test each public method with success and failure paths using `HttpClientTestingModule` if HTTP is involved.

7. **Run the tests**:
   ```bash
   npx ng test --include="**/path/to/file.spec.ts"
   ```
   Fix failures before reporting done.

8. Report: number of test cases added, coverage areas, and any gaps left intentionally.
