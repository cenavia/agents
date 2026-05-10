---
name: react-forms
description: |
  Form handling and validation in React with JS and TS. Covers React Hook Form
  (useForm, Controller, FormProvider, useFormContext, field arrays, async validation),
  Zod schema validation (z.object, z.string, refinements, transform, discriminated
  unions, zodResolver), and Yup schema validation (yup.object, yup.string,
  custom methods, yupResolver). Includes controlled/uncontrolled patterns,
  multi-step forms, and accessibility.

  USE WHEN: user mentions "React Hook Form", "useForm", "Controller", "register",
  "formState", "zodResolver", "yupResolver", "Zod schema", "yup schema",
  "form validation", "field arrays", "useFieldArray", "FormProvider",
  "useFormContext", "form submission", "form errors", asks about "controlled forms",
  "uncontrolled forms", "multi-step form", "file upload form"

  DO NOT USE FOR: state outside forms — use react-dev-suite:react-state,
  server mutations — use react-dev-suite:react-data
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React Forms & Validation — JS & TS

```bash
npm install react-hook-form zod @hookform/resolvers
```

---

## React Hook Form + Zod (TS)

### Basic Form

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const loginSchema = z.object({
  email:    z.string().email('Invalid email'),
  password: z.string().min(8, 'Min 8 characters'),
  remember: z.boolean().default(false),
});

type LoginFormData = z.infer<typeof loginSchema>;

function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting, isDirty },
    setError,
    reset,
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: '', password: '', remember: false },
  });

  async function onSubmit(data: LoginFormData) {
    try {
      await authApi.login(data);
      reset();
    } catch (err) {
      setError('email', { message: 'Invalid credentials' });
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <label htmlFor="email">Email</label>
      <input id="email" type="email" {...register('email')} aria-invalid={!!errors.email} />
      {errors.email && <p role="alert">{errors.email.message}</p>}

      <label htmlFor="password">Password</label>
      <input id="password" type="password" {...register('password')} aria-invalid={!!errors.password} />
      {errors.password && <p role="alert">{errors.password.message}</p>}

      <label>
        <input type="checkbox" {...register('remember')} />
        Remember me
      </label>

      <button type="submit" disabled={isSubmitting || !isDirty}>
        {isSubmitting ? 'Logging in…' : 'Login'}
      </button>
    </form>
  );
}
```

### Controller — UI Library Components

```tsx
import { useForm, Controller } from 'react-hook-form';
import Select from 'react-select';

function ProfileForm() {
  const { control, handleSubmit } = useForm<ProfileData>({
    resolver: zodResolver(profileSchema),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {/* Use Controller when the component doesn't expose a native ref */}
      <Controller
        name="country"
        control={control}
        render={({ field, fieldState: { error } }) => (
          <div>
            <Select
              {...field}
              options={countryOptions}
              placeholder="Select country"
            />
            {error && <p role="alert">{error.message}</p>}
          </div>
        )}
      />
    </form>
  );
}
```

### Dynamic Field Arrays

```tsx
import { useFieldArray } from 'react-hook-form';

const schema = z.object({
  team: z.array(
    z.object({
      name:  z.string().min(1, 'Required'),
      role:  z.string().min(1, 'Required'),
    })
  ).min(1, 'Add at least one member'),
});

function TeamForm() {
  const { register, control, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema),
    defaultValues: { team: [{ name: '', role: '' }] },
  });

  const { fields, append, remove } = useFieldArray({ control, name: 'team' });

  return (
    <form onSubmit={handleSubmit(console.log)}>
      {fields.map((field, index) => (
        <div key={field.id}>
          <input {...register(`team.${index}.name`)} placeholder="Name" />
          {errors.team?.[index]?.name && <p>{errors.team[index].name.message}</p>}

          <input {...register(`team.${index}.role`)} placeholder="Role" />
          {errors.team?.[index]?.role && <p>{errors.team[index].role.message}</p>}

          <button type="button" onClick={() => remove(index)}>Remove</button>
        </div>
      ))}

      <button type="button" onClick={() => append({ name: '', role: '' })}>Add Member</button>
      <button type="submit">Save Team</button>
    </form>
  );
}
```

### Shared Form with FormProvider

```tsx
import { FormProvider, useForm, useFormContext } from 'react-hook-form';

// Child component accesses parent form context
function AddressSection() {
  const { register, formState: { errors } } = useFormContext<CheckoutFormData>();
  return (
    <fieldset>
      <legend>Shipping Address</legend>
      <input {...register('address.street')} placeholder="Street" />
      {errors.address?.street && <p>{errors.address.street.message}</p>}
    </fieldset>
  );
}

// Parent wraps with FormProvider
function CheckoutForm() {
  const methods = useForm<CheckoutFormData>({ resolver: zodResolver(checkoutSchema) });
  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)}>
        <AddressSection />
        <PaymentSection />
        <button type="submit">Place Order</button>
      </form>
    </FormProvider>
  );
}
```

---

## Zod Schemas

### Common Patterns

```ts
import { z } from 'zod';

// String validations
const emailSchema = z.string().email().toLowerCase().trim();
const passwordSchema = z.string().min(8).max(72).regex(/[A-Z]/, 'Need uppercase');

// Number
const ageSchema = z.number().int().min(0).max(120);

// Optional vs nullable
const bio = z.string().optional();         // string | undefined
const avatar = z.string().nullable();      // string | null

// Enum
const roleSchema = z.enum(['admin', 'user', 'guest']);
type Role = z.infer<typeof roleSchema>;   // 'admin' | 'user' | 'guest'

// Coerce (for form inputs which are strings)
const priceSchema = z.coerce.number().positive();

// Custom refinement
const passwordConfirmSchema = z.object({
  password: z.string().min(8),
  confirm:  z.string(),
}).refine(data => data.password === data.confirm, {
  message: 'Passwords do not match',
  path: ['confirm'],
});

// Transform — normalize data
const phoneSchema = z.string().transform(v => v.replace(/\D/g, ''));

// Discriminated union
const eventSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('click'), x: z.number(), y: z.number() }),
  z.object({ type: z.literal('keydown'), key: z.string() }),
]);

// Partial / Pick / Omit
const updateUserSchema = userSchema.partial().required({ id: true });
```

---

## Yup (alternative — common with legacy codebases)

```bash
npm install yup @hookform/resolvers
```

```ts
import * as yup from 'yup';

const signupSchema = yup.object({
  name:     yup.string().required('Name is required').min(2),
  email:    yup.string().email('Invalid email').required(),
  age:      yup.number().positive().integer().min(18, 'Must be 18+'),
  password: yup.string().min(8).required(),
  confirm:  yup.string()
    .oneOf([yup.ref('password')], 'Passwords must match')
    .required(),
});

type SignupData = yup.InferType<typeof signupSchema>;

// In useForm:
import { yupResolver } from '@hookform/resolvers/yup';
const { register, handleSubmit } = useForm({ resolver: yupResolver(signupSchema) });
```

---

## Multi-Step Form Pattern

```tsx
const STEPS = ['Account', 'Profile', 'Review'] as const;

function MultiStepForm() {
  const [step, setStep] = useState(0);
  const methods = useForm<FullFormData>({ resolver: zodResolver(fullSchema), mode: 'onChange' });

  const stepFields: (keyof FullFormData)[][] = [
    ['email', 'password'],
    ['name', 'bio'],
  ];

  async function handleNext() {
    const valid = await methods.trigger(stepFields[step]);
    if (valid) setStep(s => s + 1);
  }

  return (
    <FormProvider {...methods}>
      <div role="progressbar" aria-valuenow={step + 1} aria-valuemax={STEPS.length}>
        Step {step + 1} of {STEPS.length}: {STEPS[step]}
      </div>

      <form onSubmit={methods.handleSubmit(onFinalSubmit)}>
        {step === 0 && <AccountStep />}
        {step === 1 && <ProfileStep />}
        {step === 2 && <ReviewStep />}

        <div>
          {step > 0 && <button type="button" onClick={() => setStep(s => s - 1)}>Back</button>}
          {step < STEPS.length - 1
            ? <button type="button" onClick={handleNext}>Next</button>
            : <button type="submit" disabled={methods.formState.isSubmitting}>Submit</button>
          }
        </div>
      </form>
    </FormProvider>
  );
}
```

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| Calling `register()` inside conditional | Register unconditionally; hide with CSS or `display: none` |
| Not using `noValidate` on `<form>` | Add `noValidate` — browser validation conflicts with RHF |
| Manual error state instead of `setError` | Use `setError` for server errors — keeps form aware |
| Forgetting `key={field.id}` in field arrays | Always use `field.id` — index causes wrong re-renders |
| Yup `async` validators on every keystroke | Set `mode: 'onBlur'` or debounce async validations |
