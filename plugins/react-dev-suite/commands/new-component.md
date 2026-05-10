---
description: Generate a production-ready React component with TypeScript. Usage: /react-dev-suite:new-component <ComponentName> [variant: fc|forwardRef|compound] [style: tailwind|mui|css-module]
---

Generate a complete, production-ready React component based on the arguments: $ARGUMENTS

---

## Step 0 — Load project context

Read `.rds-context.json` from the current directory:
```bash
cat .rds-context.json 2>/dev/null
```
If found, use `styling`, `architecture`, and `srcDir` to adapt generated code.
If not found, detect styling from `package.json` and detect `architecture` from the filesystem:

```bash
find src -maxdepth 3 -type d 2>/dev/null | sort | head -40
```

Infer architecture (first match wins):
- `src/domain/` + `src/infrastructure/` → `hexagonal`
- `src/components/atoms/` or `src/components/molecules/` → `atomic`
- `src/features/` + any `views/` subdirectory inside → `modular`
- `src/features/` exists → `screaming`
- `src/pages/` + `src/components/` + no `src/features/` → `file-type`
- None matched → ask the user

**Rule:** Place the component where the existing project structure dictates. Never suggest reorganizing to a different pattern unless the user explicitly requests it.

Key adaptations:
- `styling: tailwind` → use Tailwind classes + `cn()` (default if `style` arg omitted)
- `styling: mui` → use `sx` prop or `styled()` (default if `style` arg omitted)
- `architecture` → determines the destination directory (see below)

The `style` argument in `$ARGUMENTS` always overrides the context default.

### Destination path by architecture

When generating a **shared/reusable** component (no specific feature mentioned):

| `architecture` | Destination |
|---|---|
| `screaming` | `src/shared/ui/<ComponentName>/` |
| `file-type` | `src/components/<ComponentName>/` |
| `modular` | `src/shared/ui/<ComponentName>/` |
| `atomic` | Ask: atom / molecule / organism? → `src/components/<level>/<ComponentName>/` |

When generating a **feature-specific** component (a feature name is provided or implied):

| `architecture` | Destination |
|---|---|
| `screaming` | `src/features/<feature>/components/<ComponentName>/` |
| `file-type` | `src/pages/<Feature>/components/<ComponentName>/` |
| `modular` | `src/features/<Feature>/components/<ComponentName>/` |
| `atomic` | `src/features/<feature>/<molecules\|organisms>/<ComponentName>/` |

---

## Instructions

Parse the arguments to determine:
- **ComponentName** — PascalCase name (required)
- **variant** — component type (default: `fc`)
  - `fc` — functional component
  - `forwardRef` — component that forwards a ref (useful for form inputs, UI primitives)
  - `compound` — compound component with sub-components (tabs, accordion, menu)
- **style** — styling approach (default: detect from project, fallback: `tailwind`)
  - `tailwind` — Tailwind utility classes + `cn()` helper
  - `mui` — Material UI `sx` prop or `styled()`
  - `css-module` — CSS Modules with `.module.css`

## What to generate

For each component, produce ALL of the following files:

### 1. Component file — `src/components/<ComponentName>/<ComponentName>.tsx`

Requirements:
- Typed `interface <ComponentName>Props` with JSDoc comments on non-obvious props
- Proper accessibility attributes (`role`, `aria-*`, `tabIndex` where needed)
- Display name set if using `forwardRef` or `memo`
- For `compound`: implement with `createContext` + sub-components attached as static properties
- For `forwardRef`: use `React.forwardRef<HTMLElement, Props>` with correct HTML element type

### 2. Index barrel — `src/components/<ComponentName>/index.ts`

Re-export component and its types:
```ts
export { <ComponentName> } from './<ComponentName>';
export type { <ComponentName>Props } from './<ComponentName>';
```

### 3. Test file — `src/components/<ComponentName>/<ComponentName>.test.tsx`

Requirements:
- Vitest + React Testing Library
- At minimum: renders correctly, handles main interaction, accessibility check with `axe`
- Use `userEvent.setup()` for interactions
- Use `getByRole` as primary query

### 4. Stories file (if Storybook detected) — `src/components/<ComponentName>/<ComponentName>.stories.tsx`

If `storybook` or `.storybook/` exists in the project, generate a stories file.

## Style templates

### Tailwind (fc variant)
```tsx
import { cn } from '@/lib/utils';

interface <ComponentName>Props {
  className?: string;
  children?: React.ReactNode;
}

export function <ComponentName>({ className, children, ...props }: <ComponentName>Props) {
  return (
    <div
      className={cn(
        'rounded-lg border bg-card p-4 shadow-sm',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
```

### MUI (fc variant)
```tsx
import Box from '@mui/material/Box';

export function <ComponentName>({ children, sx, ...props }: <ComponentName>Props) {
  return (
    <Box
      sx={{ borderRadius: 2, bgcolor: 'background.paper', p: 2, boxShadow: 1, ...sx }}
      {...props}
    >
      {children}
    </Box>
  );
}
```

## After generating

- Check if `src/components/index.ts` exists and add an export line
- Check if `src/lib/utils.ts` exists; if not, offer to create it with the `cn()` helper
- Confirm: "Generated <ComponentName> in `src/components/<ComponentName>/`. Import with: `import { <ComponentName> } from '@/components/<ComponentName>'`"
