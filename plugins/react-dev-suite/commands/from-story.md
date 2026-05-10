---
description: Analyzes a user story or requirement and orchestrates the full React implementation plan — decomposing it into features, components, hooks, forms, queries, stores, and tests, then executing generation in the correct order. Reads .rds-context.json if present to generate stack-compatible code. Usage: /react-dev-suite:from-story <user story or requirement text>
---

Analyze the following user story or requirement and generate a complete, structured React implementation:

$ARGUMENTS

---

## Phase 0 — Load project context

Before parsing the story, read the project context to generate stack-compatible code.

**Step 1:** Check if `.rds-context.json` exists in the current working directory:

```bash
cat .rds-context.json 2>/dev/null
```

**Step 2:** If the file exists, load it and use these values for ALL subsequent generation decisions:

```json
{
  "stack":        "modern|classic|minimal",
  "routing":      "tanstack-router|react-router",
  "stateLib":     "zustand|none",
  "dataFetching": "tanstack-query|axios",
  "forms":        "rhf-zod|none",
  "styling":      "tailwind|mui",
  "architecture": "screaming|file-type|modular|atomic",
  "testing":      "vitest-rtl",
  "srcDir":       "src",
  "apiBaseUrl":   "/api"
}
```

**Step 3:** If the file does NOT exist, auto-detect from the project:

```bash
cat package.json
cat vite.config.ts 2>/dev/null || cat vite.config.js 2>/dev/null
ls src/routes/ 2>/dev/null
find src -maxdepth 3 -type d 2>/dev/null | sort | head -40
```

Infer the stack from `package.json` dependencies:
- `@tanstack/react-router` present → `routing: tanstack-router`
- `react-router-dom` present → `routing: react-router`
- `zustand` present → `stateLib: zustand`
- `@tanstack/react-query` present → `dataFetching: tanstack-query`
- `react-hook-form` + `zod` present → `forms: rhf-zod`
- `tailwindcss` present → `styling: tailwind`
- `@mui/material` present → `styling: mui`

Infer `architecture` from the folder structure (first match wins):
- `src/domain/` + `src/infrastructure/` exist → `hexagonal`
- `src/components/atoms/` or `src/components/molecules/` exist → `atomic`
- `src/features/` exists AND a `views/` subdirectory is found inside any feature → `modular`
- `src/features/` exists → `screaming`
- `src/pages/` + `src/components/` exist but no `src/features/` → `file-type`
- None matched → ask the user which architecture they use before proceeding

**Rule:** Use the detected architecture for all generated paths. Do not propose refactoring to a different pattern unless the user explicitly asks.

**Step 4:** Display the resolved context at the top of the plan:

```
📦 Project context loaded from: .rds-context.json | package.json

  Stack:        modern (React 19)
  Routing:      TanStack Router
  State:        Zustand
  Data:         TanStack Query + Axios
  Forms:        React Hook Form + Zod
  Styling:      Tailwind CSS
  Architecture: Screaming (feature-first)
  Testing:      Vitest + RTL + MSW
```

> If none of the above detection methods work, state "No context detected — I'll use the modern stack as default" and proceed.

---

## Phase 1 — Parse & Understand

Read the requirement carefully and extract:

1. **Domain entities** — nouns that represent data (User, Product, Order, Cart, Invoice…)
2. **Actions / verbs** — what the user does (create, edit, delete, filter, search, checkout, login…)
3. **UI surfaces** — pages, modals, forms, lists, detail views, dashboards
4. **Data flows** — what data is fetched, mutated, or stored
5. **Business rules** — validations, conditions, permissions, constraints mentioned
6. **Integrations implied** — API calls, real-time updates, file uploads, payments

Ask yourself:
- Is there a **form** needed? (any "create", "edit", "submit", "fill in" language)
- Is there a **list + detail** pattern? (any "see all", "view details", "browse", "search")
- Is there **state** that outlives a single component? (cart, auth, filters, preferences)
- Is there **async data** involved? (fetching, loading, server interaction)
- Are there **protected routes**? (any "only logged in", "admin only", "requires…")

---

## Phase 2 — Implementation Plan

Present a clear plan **before generating anything**.

### Project context
[Stack resolved in Phase 0]

### Story Summary
[1-2 sentence interpretation of what needs to be built]

### Entities & Types
List each entity with its key fields:
```
User: { id, name, email, role }
Product: { id, name, price, category, stock }
```

### What will be generated

The commands and their arguments MUST be compatible with the stack detected in Phase 0:
- If `routing: tanstack-router` → route files use `createFileRoute`
- If `routing: react-router` → route files use `<Route>` components
- If `stateLib: zustand` → generate Zustand stores; if `none` → use `useState` + Context
- If `dataFetching: tanstack-query` → generate `queryOptions` + mutations; if `axios` → use Axios directly in hooks
- If `forms: rhf-zod` → use React Hook Form + Zod; if `none` → use controlled components
- If `styling: tailwind` → use Tailwind classes + `cn()`; if `mui` → use `sx` prop + `styled()`

| # | Command | Arguments | Purpose |
|---|---|---|---|
| 1 | `new-feature` | `<name> with:...` | Feature module scaffold |
| 2 | `new-query` | `<resource> operations:...` | Data layer |
| 3 | `new-store` | `<name> fields:... with:...` | State (if stateLib: zustand) |
| 4 | `new-form` | `<name> fields:...` | Form (if forms: rhf-zod) |
| 5 | `new-component` | `<name> variant:... style:<styling>` | UI components |
| 6 | `gen-tests` | `<file> coverage:...` | Test coverage |

### Files to be created

File paths depend on `architecture` from context:

#### architecture: screaming (default)
```
<srcDir>/features/<domain>/
  components/   → feature-private components
  hooks/        → feature-private hooks
  queries.ts    (if tanstack-query)
  mutations.ts
  services.ts
  store.ts      (if zustand)
  types.ts
  index.ts      ← barrel export (public API)
<srcDir>/shared/ui/<ComponentName>/ → shared UI components
```

#### architecture: file-type
```
<srcDir>/pages/<Domain>/
  components/   → page-specific components
  <Domain>.tsx  → main page component
<srcDir>/components/<ComponentName>/ → shared components
<srcDir>/services/<domain>Service.ts
<srcDir>/hooks/use<Domain>.ts
```

#### architecture: modular
```
<srcDir>/features/<Domain>/
  views/        → presentational views (no data fetching)
  pages/        → smart containers (useQuery + mutations)
  components/   → feature-private components
  services/
  hooks/
  index.ts
<srcDir>/shared/ui/<ComponentName>/ → shared UI components
```

#### architecture: atomic
```
<srcDir>/features/<domain>/
  organisms/    → complex feature-specific sections
  molecules/    → composed feature components
  atoms/        → feature-specific primitives
  services.ts
  store.ts      (if zustand)
  types.ts
  index.ts
<srcDir>/components/atoms/<ComponentName>/    → shared atoms
<srcDir>/components/molecules/<Name>/         → shared molecules
<srcDir>/components/organisms/<Name>/         → shared organisms
```

### Routing integration
Show the exact routing code based on context:

#### TanStack Router
```tsx
// src/routes/<feature>/index.tsx
import { createFileRoute } from '@tanstack/react-router';
import { <Feature>Page } from '@/features/<feature>';
export const Route = createFileRoute('/<feature>')({ component: <Feature>Page });
```

#### React Router
```tsx
// In src/App.tsx or router config:
import { <Feature>Page } from '@/features/<feature>';
<Route path="/<feature>" element={<Feature>Page />} />
```

### Open questions (ask the user if critical)
- List any ambiguous business rules or missing info that would change the architecture
- If non-blocking, state the assumption made

---

## Phase 3 — Execute

After presenting the plan, ask:

> "¿Procedo con este plan? ¿O quieres ajustar algo antes?"

If the user confirms, execute **each step in order**, always respecting the stack from Phase 0:

1. **Types first** — `types.ts` with all interfaces
2. **Data layer** — `new-query` for each API resource (tanstack-query) or typed Axios hooks (axios)
3. **State** — `new-store` if `stateLib: zustand`; otherwise `useState` + Context
4. **Feature scaffold** — `new-feature` for the main domain
5. **Forms** — `new-form` if `forms: rhf-zod`; otherwise controlled component
6. **Components** — `new-component` with correct `style:<styling>`
7. **Tests** — `gen-tests` for main components and hooks

For each step, show progress:
```
→ [1/7] Types — Creating src/features/products/types.ts
→ [2/7] Data layer — Creating queries.ts, services.ts, mutations.ts
→ [3/7] Store — Creating src/features/products/store.ts (Zustand)
→ [4/7] Feature scaffold — Creating components/
→ [5/7] Form — Creating CreateProductForm.tsx (RHF + Zod)
→ [6/7] Components — Creating ProductCard.tsx (Tailwind)
→ [7/7] Tests — Creating ProductList.test.tsx (coverage: integration)
```

---

## Phase 4 — Integration Summary

### ✅ Generated files
[List all created files with paths]

### Integration checklist

- [ ] Add route (see routing code above)
- [ ] `npm run typecheck` — verify no TypeScript errors
- [ ] `npm test` — verify all generated tests pass
- [ ] Set `VITE_API_URL` in `.env` if not already set

### Next entry point
```tsx
// Exact code to wire the feature into the app, based on detected routing library
```

---

## Examples of valid input

```
/react-dev-suite:from-story As a user, I want to browse products by category,
add them to a cart, and proceed to checkout with my shipping address.

/react-dev-suite:from-story The admin needs a dashboard to manage registered users:
view the full list, search by name or email, edit user roles, and deactivate accounts.

/react-dev-suite:from-story Build a comment system where authenticated users can
post comments on articles, reply to other comments, and delete their own comments.

/react-dev-suite:from-story Create a notification center that shows real-time
notifications via SSE, allows marking as read, and persists read/unread state.
```
