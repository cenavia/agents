---
description: Generate a React Hook Form + Zod form component with full validation. Usage: /react-dev-suite:new-form <FormName> [fields: name:string,email:email,age:number,role:enum(admin|user)] [variant: simple|multi-step|dialog]
---

Generate a complete form component based on: $ARGUMENTS

---

## Step 0 — Load project context

Read `.rds-context.json` from the current directory:
```bash
cat .rds-context.json 2>/dev/null
```
If found, use `forms`, `styling`, `architecture`, and `srcDir`.
If not found, detect from `package.json` and infer `architecture` from the filesystem:

```bash
find src -maxdepth 3 -type d 2>/dev/null | sort | head -40
```

Use first match: `src/domain/`+`src/infrastructure/` → `hexagonal` | `src/components/atoms/` → `atomic` | `src/features/*/views/` → `modular` | `src/features/` → `screaming` | `src/pages/`+`src/components/` → `file-type`.

Output path adapts to architecture:
- `screaming` / `modular`: `src/features/<feature>/components/<FormName>.tsx` (or `src/shared/ui/` if no specific feature)
- `file-type`: `src/pages/<Feature>/components/<FormName>.tsx` (or `src/components/<FormName>/` if shared)
- `atomic`: `src/features/<feature>/molecules/<FormName>.tsx` (forms are molecules)
- `hexagonal`: `src/infrastructure/components/<FormName>.tsx`

**Rule:** Never propose restructuring to a different architecture. Adapt silently to what already exists.

Key adaptations:
- `forms: rhf-zod` → React Hook Form + Zod (standard output)
- `forms: none` → generate a controlled component form using only `useState` (no RHF, no Zod)
- `styling: tailwind` → Tailwind classes on all form elements
- `styling: mui` → MUI `TextField`, `Select`, `Button`, `FormControl` components

#### Controlled-only mode (when `forms: none`)
```tsx
function <FormName>({ onSuccess }: { onSuccess: (data: FormData) => void }) {
  const [values, setValues] = useState({ field: '' });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);

  function validate() {
    const errs: Record<string, string> = {};
    if (!values.field) errs.field = 'Required';
    return errs;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length) { setErrors(errs); return; }
    setSubmitting(true);
    try { await onSuccess(values); }
    finally { setSubmitting(false); }
  }
  // ...
}
```

---

## Instructions

Parse the arguments:
- **FormName** — PascalCase (e.g. `LoginForm`, `CreateUserForm`, `CheckoutForm`)
- **fields** — comma-separated field definitions: `<name>:<type>`
  - Types: `string`, `email`, `password`, `number`, `boolean`, `date`, `enum(val1|val2)`, `file`, `tel`, `url`, `textarea`
  - Modifiers: append `?` for optional, `[]` for array field (useFieldArray)
  - Examples: `name:string`, `email:email`, `role:enum(admin|user|guest)?`, `tags:string[]`
- **variant** — form layout (default: `simple`)
  - `simple` — single-page form
  - `multi-step` — wizard with step validation
  - `dialog` — form inside a modal/dialog

## What to generate

### 1. Zod Schema (`<formName>Schema`)

Map each field type to the correct Zod validator:

| Field type | Zod validator |
|---|---|
| `string` | `z.string().min(1, 'Required')` |
| `email` | `z.string().email('Invalid email address')` |
| `password` | `z.string().min(8, 'At least 8 characters').regex(/[A-Z]/, 'Need uppercase').regex(/[0-9]/, 'Need number')` |
| `number` | `z.coerce.number().min(0)` |
| `boolean` | `z.boolean()` |
| `date` | `z.string().date()` or `z.coerce.date()` |
| `enum(a\|b)` | `z.enum(['a', 'b'])` |
| `tel` | `z.string().regex(/^\+?[\d\s\-()]{7,}$/, 'Invalid phone')` |
| `url` | `z.string().url('Invalid URL')` |
| `textarea` | `z.string().min(1).max(2000)` |
| `file` | `z.instanceof(File).refine(f => f.size < 5_000_000, 'Max 5MB')` |
| `string[]` | `z.array(z.string().min(1)).min(1, 'Add at least one')` |

For `password` fields: auto-add `confirm<FieldName>` field + `.refine()` cross-field check.

### 2. Form Component (`src/components/<FormName>/<FormName>.tsx`)

Requirements:
- `noValidate` on `<form>` element
- `aria-invalid` on error fields
- `role="alert"` on error messages
- `disabled={isSubmitting}` on submit button
- Loading indicator during submission
- Server error display (via `setError('root', { message: '...' })`)
- `reset()` after successful submission
- Proper `htmlFor` + `id` pairing on all label/input pairs
- `defaultValues` prop for edit mode
- `onSuccess` callback prop

### 3. Test file (`<FormName>.test.tsx`)

Cover:
- Renders all fields
- Shows validation errors on empty submit
- Shows cross-field error (confirm password)
- Calls onSuccess with correct data on valid submit
- Disables button during submission
- Shows server error when onSubmit throws

## Template — simple variant

```tsx
const <formName>Schema = z.object({
  // fields mapped here
});

type <FormName>Data = z.infer<typeof <formName>Schema>;

interface <FormName>Props {
  defaultValues?: Partial<<FormName>Data>;
  onSuccess: (data: <FormName>Data) => Promise<void>;
}

export function <FormName>({ defaultValues, onSuccess }: <FormName>Props) {
  const {
    register,
    handleSubmit,
    control,
    setError,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<<FormName>Data>({
    resolver: zodResolver(<formName>Schema),
    defaultValues: defaultValues ?? {},
  });

  async function onSubmit(data: <FormName>Data) {
    try {
      await onSuccess(data);
      reset();
    } catch (err) {
      setError('root', { message: (err as Error).message });
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      {/* Fields here */}
      {errors.root && <p role="alert">{errors.root.message}</p>}
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Saving…' : 'Submit'}
      </button>
    </form>
  );
}
```

## Multi-step variant extras

For `multi-step`: generate a `steps` array, per-step field groups, and a `handleNext` function that calls `trigger(stepFields[currentStep])` before advancing.

## After generating

- Show import: `import { <FormName> } from '@/components/<FormName>'`
- Show usage example:
```tsx
<FormName
  onSuccess={async (data) => {
    await createResource(data);
    router.push('/list');
  }}
/>
```
