---
description: Scaffold a complete feature module with components, hooks, queries, services, store, and types. Usage: /react-dev-suite:new-feature <featureName> [api-base: /users] [with: store|router|form]
---

Scaffold a complete, production-ready feature module based on: $ARGUMENTS

---

## Step 0 — Load project context

Read `.rds-context.json` from the current directory:
```bash
cat .rds-context.json 2>/dev/null
```
If found, use `routing`, `stateLib`, `dataFetching`, `forms`, `styling`, `architecture`, and `srcDir` values to adapt all generated code.
If not found, detect from `package.json` (look for `@tanstack/react-router`, `react-router-dom`, `zustand`, `@tanstack/react-query`, `tailwindcss`, `@mui/material`) and detect `architecture` from the filesystem:

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

**Rule:** Generate files matching the detected architecture. Never suggest changing the architecture unless the user explicitly requests a refactor.

Key adaptations:
- `routing: tanstack-router` → route files use `createFileRoute`; `react-router` → `<Route>` component
- `stateLib: none` → skip `store.ts`, use `useState` + Context instead
- `dataFetching: axios` → skip `queryOptions`, generate typed Axios hooks instead
- `styling: tailwind` → Tailwind classes + `cn()`; `mui` → `sx` prop + `styled()`

---

## Instructions

Parse the arguments:
- **featureName** — kebab-case or camelCase name (e.g. `users`, `product-catalog`, `auth`)
- **api-base** — base API path (e.g. `/users`, `/products`) — default: `/<featureName>`
- **with** — optional extras (comma-separated)
  - `store` — include a Zustand store slice
  - `router` — include route files for React Router or TanStack Router (auto-detect)
  - `form` — include a create/edit form with React Hook Form + Zod

## What to generate

Read the project to detect: routing library, state library, styling approach, and existing structure conventions.

### Scaffold structure

The output path and internal structure depend on `architecture` from context:

#### architecture: screaming (default)
```
src/features/<featureName>/
├── components/
│   ├── <FeatureName>List.tsx         ← list view
│   ├── <FeatureName>Card.tsx         ← single item card
│   ├── <FeatureName>Detail.tsx       ← detail view
│   └── <FeatureName>Form.tsx         ← create/edit form (if `with: form`)
├── hooks/
│   └── use<FeatureName>.ts
├── queries.ts
├── services.ts
├── store.ts                           ← (if `with: store`)
├── types.ts
├── routes.tsx                         ← (if `with: router`)
└── index.ts                           ← public API — only export from here
```
Shared components go to `src/shared/ui/<ComponentName>/`.

#### architecture: file-type
```
src/pages/<FeatureName>/
├── components/
│   ├── <FeatureName>List.tsx
│   └── <FeatureName>Form.tsx
├── <FeatureName>.tsx                  ← main page component
└── <FeatureName>.test.tsx
```
Services go to `src/services/<featureName>Service.ts`.
Hooks go to `src/hooks/use<FeatureName>.ts`.
Shared components go to `src/components/<ComponentName>/`.

#### architecture: modular
```
src/features/<FeatureName>/
├── views/
│   └── <FeatureName>View.tsx          ← pure presentation (no data fetching)
├── pages/
│   └── <FeatureName>Page.tsx          ← smart container (useQuery + mutations)
├── components/
│   ├── <FeatureName>List.tsx
│   └── <FeatureName>Form.tsx
├── services/
│   └── <featureName>Service.ts
├── hooks/
│   └── use<FeatureName>.ts
├── types.ts
└── index.ts
```

#### architecture: atomic
```
src/features/<featureName>/
├── organisms/
│   └── <FeatureName>List.tsx          ← complex feature sections
├── molecules/
│   └── <FeatureName>Card.tsx          ← composed components
├── atoms/                             ← feature-specific primitives (if any)
├── services.ts
├── queries.ts
├── store.ts                           ← (if `with: store`)
├── types.ts
└── index.ts
```
Shared components go to `src/components/atoms/`, `molecules/`, or `organisms/` depending on complexity.

### File contents to generate

#### `types.ts`
```ts
export interface <FeatureName> {
  id: string;
  // Add fields based on featureName context
  createdAt: string;
  updatedAt: string;
}

export interface Create<FeatureName>Dto extends Omit<<FeatureName>, 'id' | 'createdAt' | 'updatedAt'> {}
export interface Update<FeatureName>Dto extends Partial<Create<FeatureName>Dto> {}

export interface <FeatureName>Filters {
  page?: number;
  pageSize?: number;
  search?: string;
}
```

#### `services.ts`
Typed Axios service using the detected `api` instance:
```ts
import { api } from '@/lib/api';
import type { <FeatureName>, Create<FeatureName>Dto, Update<FeatureName>Dto, <FeatureName>Filters } from './types';

export const <featureName>Service = {
  getAll:   (filters?: <FeatureName>Filters)             => api.get<{ data: <FeatureName>[]; total: number }>('<api-base>', { params: filters }).then(r => r.data),
  getById:  (id: string)                                  => api.get<<FeatureName>>(`<api-base>/${id}`).then(r => r.data),
  create:   (dto: Create<FeatureName>Dto)                 => api.post<<FeatureName>>('<api-base>', dto).then(r => r.data),
  update:   (id: string, dto: Update<FeatureName>Dto)     => api.patch<<FeatureName>>(`<api-base>/${id}`, dto).then(r => r.data),
  remove:   (id: string)                                  => api.delete(`<api-base>/${id}`),
};
```

#### `queries.ts`
TanStack Query query objects:
```ts
import { queryOptions, infiniteQueryOptions } from '@tanstack/react-query';
import { <featureName>Service } from './services';
import type { <FeatureName>Filters } from './types';

export const <featureName>Queries = {
  all:    (filters?: <FeatureName>Filters) => queryOptions({
    queryKey: ['<featureName>', filters],
    queryFn:  () => <featureName>Service.getAll(filters),
  }),
  detail: (id: string) => queryOptions({
    queryKey: ['<featureName>', id],
    queryFn:  () => <featureName>Service.getById(id),
    enabled:  !!id,
  }),
};
```

#### `store.ts` (if `with: store`)
Zustand slice with devtools:
```ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface <FeatureName>State {
  selected: string | null;
  setSelected: (id: string | null) => void;
}

export const use<FeatureName>Store = create<<FeatureName>State>()(
  devtools(
    (set) => ({
      selected: null,
      setSelected: (id) => set({ selected: id }),
    }),
    { name: '<FeatureName>Store' }
  )
);
```

#### `index.ts` — public barrel
Only export what external modules need:
```ts
export * from './types';
export * from './queries';
export { <featureName>Service } from './services';
export { use<FeatureName>Store } from './store';  // if store generated
export { <FeatureName>List } from './components/<FeatureName>List';
export { <FeatureName>Detail } from './components/<FeatureName>Detail';
```

## After generating

1. Show the complete file tree created
2. Show the import path: `import { <FeatureName>List } from '@/features/<featureName>'`
3. If `with: router`, show how to add the routes to the router config
4. Run TypeScript check mentally — flag any type you left as `unknown` that needs real types
