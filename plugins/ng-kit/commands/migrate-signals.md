# Migrate to Angular Signals

Migrate existing Angular code from RxJS/ngModel patterns to modern signal-based reactivity.

## Target

File or component to migrate: $ARGUMENTS

## Steps to follow

1. **Read the target file** and identify legacy patterns:
   - `BehaviorSubject` / `Subject` used for local state
   - `async` pipe in templates for local (non-HTTP) streams
   - `ngModel` two-way binding on simple form fields (v21+ only)
   - `@Input()` decorator style (migrate to `input<T>()` signal input)
   - `@Output()` decorator style (migrate to `output<T>()`)
   - `ngOnChanges` reacting to input changes

2. **Migration map**:

   | Legacy | Modern signal equivalent |
   |---|---|
   | `new BehaviorSubject<T>(val)` | `signal<T>(val)` |
   | `.pipe(map(...))` for derived state | `computed(() => ...)` |
   | `ngOnChanges` reacting to an input | `effect(() => { this.myInput() })` |
   | `@Input() value: T` | `value = input<T>()` |
   | `@Output() changed` | `changed = output<T>()` |
   | `async` pipe on local subject | read signal directly in template |
   | `ngModel` (v21+) | Signal Forms (`FormField`) |

3. **Preserve RxJS** for:
   - HTTP calls (use `rxResource()` to bridge to signals)
   - WebSocket / SSE streams
   - Complex multi-source async composition

4. **Update the template**: remove `| async`, use `()` signal calls, replace `[(ngModel)]` with signal form bindings.

5. **Run `npx ng build`** and fix errors.

6. **Run existing tests** (`npx ng test`) — fix broken specs caused by the migration.

7. Report: a before/after diff summary of what changed and why each substitution was made.
