---
description: Generate TanStack Query hooks + Axios service for a REST resource. Usage: /react-dev-suite:new-query <resourceName> [api-base: /users] [operations: list,get,create,update,delete,infinite]
---

Generate a complete data layer for a REST resource based on: $ARGUMENTS

---

## Step 0 — Load project context

Read `.rds-context.json` from the current directory:
```bash
cat .rds-context.json 2>/dev/null
```
If found, use `dataFetching`, `apiBaseUrl`, `architecture`, and `srcDir`.
If not found, detect from `package.json` and infer `architecture` from the filesystem:

```bash
find src -maxdepth 3 -type d 2>/dev/null | sort | head -40
```

Use first match: `src/domain/`+`src/infrastructure/` → `hexagonal` | `src/components/atoms/` → `atomic` | `src/features/*/views/` → `modular` | `src/features/` → `screaming` | `src/pages/`+`src/components/` → `file-type`.

Output path adapts to architecture:
- `screaming` / `modular`: `src/features/<resourceName>/` (queries.ts, services.ts, mutations.ts)
- `file-type`: `src/services/<resourceName>Service.ts` + `src/hooks/use<Resource>*.ts`
- `atomic`: same as `screaming`
- `hexagonal`: `src/infrastructure/repositories/<resourceName>Repository.ts` + `src/domain/services/`

**Rule:** Never propose restructuring to a different architecture. Adapt silently to what already exists.

Key adaptations:
- `dataFetching: tanstack-query` → generate `queryOptions` + `useMutation` hooks (standard output)
- `dataFetching: axios` → generate typed custom hooks using Axios directly (no TanStack Query)

#### Axios-only mode (when `dataFetching: axios`)
Instead of `queryOptions`, generate:
```ts
// hooks/use<Resource>List.ts
export function use<Resource>List(params?: <Resource>ListParams) {
  const [data, setData] = useState<<Resource>ListResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    <resourceName>Service.getAll(params, { signal: controller.signal })
      .then(setData)
      .catch(e => { if (e.name !== 'AbortError') setError(e); })
      .finally(() => setLoading(false));
    return () => controller.abort();
  }, [JSON.stringify(params)]);

  return { data, loading, error };
}
```

---

## Instructions

Parse the arguments:
- **resourceName** — camelCase/singular (e.g. `user`, `product`, `blogPost`)
- **api-base** — REST base path (default: `/<resourceNamePlural>`)
- **operations** — comma-separated list (default: `list,get,create,update,delete`)
  - `list` — paginated list query
  - `get` — single item query by ID
  - `create` — create mutation
  - `update` — update mutation (PATCH)
  - `delete` — delete mutation
  - `infinite` — infinite/cursor-based query for infinite scroll
  - `search` — search query with debounced input

## What to generate

### 1. Types — `src/features/<resourceName>/types.ts`

```ts
export interface <Resource> {
  id: string;
  // Infer fields from resourceName context if obvious (user → name, email; product → name, price, etc.)
  createdAt: string;
  updatedAt: string;
}

export interface <Resource>ListParams {
  page?: number;
  pageSize?: number;
  search?: string;
  sortBy?: keyof <Resource>;
  sortDir?: 'asc' | 'desc';
}

export interface <Resource>ListResponse {
  data: <Resource>[];
  total: number;
  page: number;
  pageSize: number;
}

export type Create<Resource>Dto = Omit<<Resource>, 'id' | 'createdAt' | 'updatedAt'>;
export type Update<Resource>Dto = Partial<Create<Resource>Dto>;
```

### 2. Service — `src/features/<resourceName>/services.ts`

Typed Axios service. All methods return the data directly (`.then(r => r.data)`):

```ts
import { api } from '@/lib/api';
import type { <Resource>, <Resource>ListParams, <Resource>ListResponse, Create<Resource>Dto, Update<Resource>Dto } from './types';

const BASE = '<api-base>';

export const <resourceName>Service = {
  // For each requested operation:

  // list
  getAll: (params?: <Resource>ListParams) =>
    api.get<<Resource>ListResponse>(BASE, { params }).then(r => r.data),

  // get
  getById: (id: string) =>
    api.get<<Resource>>(`${BASE}/${id}`).then(r => r.data),

  // create
  create: (dto: Create<Resource>Dto) =>
    api.post<<Resource>>(BASE, dto).then(r => r.data),

  // update
  update: (id: string, dto: Update<Resource>Dto) =>
    api.patch<<Resource>>(`${BASE}/${id}`, dto).then(r => r.data),

  // delete
  remove: (id: string) =>
    api.delete(`${BASE}/${id}`),
};
```

### 3. Query objects — `src/features/<resourceName>/queries.ts`

```ts
import { queryOptions, infiniteQueryOptions } from '@tanstack/react-query';
import { <resourceName>Service } from './services';
import type { <Resource>ListParams } from './types';

// Query key factory — all keys under ['<resourceName>']
const keys = {
  all:    ()           => ['<resourceName>'] as const,
  lists:  ()           => ['<resourceName>', 'list'] as const,
  list:   (p?: <Resource>ListParams) => ['<resourceName>', 'list', p] as const,
  details:()           => ['<resourceName>', 'detail'] as const,
  detail: (id: string) => ['<resourceName>', 'detail', id] as const,
};

export const <resourceName>Queries = {
  // list
  list: (params?: <Resource>ListParams) => queryOptions({
    queryKey: keys.list(params),
    queryFn:  () => <resourceName>Service.getAll(params),
    placeholderData: (prev) => prev,   // keep previous data while loading next page
  }),

  // get
  detail: (id: string) => queryOptions({
    queryKey: keys.detail(id),
    queryFn:  () => <resourceName>Service.getById(id),
    enabled:  Boolean(id),
  }),

  // infinite (if requested)
  infinite: (params?: Omit<<Resource>ListParams, 'page'>) => infiniteQueryOptions({
    queryKey: [...keys.lists(), 'infinite', params],
    queryFn:  ({ pageParam = 1 }) => <resourceName>Service.getAll({ ...params, page: pageParam as number }),
    getNextPageParam: (lastPage) => lastPage.page * lastPage.pageSize < lastPage.total
      ? lastPage.page + 1
      : undefined,
    initialPageParam: 1,
  }),
};
```

### 4. Mutation hooks — `src/features/<resourceName>/mutations.ts`

```ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { <resourceName>Service } from './services';
import { <resourceName>Queries } from './queries';
import type { Create<Resource>Dto, Update<Resource>Dto } from './types';

export function useCreate<Resource>() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (dto: Create<Resource>Dto) => <resourceName>Service.create(dto),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['<resourceName>', 'list'] }),
  });
}

export function useUpdate<Resource>() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: string; dto: Update<Resource>Dto }) =>
      <resourceName>Service.update(id, dto),
    onSuccess: (updated) => {
      qc.invalidateQueries({ queryKey: ['<resourceName>', 'list'] });
      qc.setQueryData(<resourceName>Queries.detail(updated.id).queryKey, updated);
    },
  });
}

export function useDelete<Resource>() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => <resourceName>Service.remove(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['<resourceName>'] }),
  });
}
```

### 5. Barrel — `src/features/<resourceName>/index.ts`

Export everything public.

## After generating

Show a complete usage example:

```tsx
import { useQuery } from '@tanstack/react-query';
import { <resourceName>Queries, useCreate<Resource>, useDelete<Resource> } from '@/features/<resourceName>';

function <Resource>Page() {
  const { data, isLoading } = useQuery(<resourceName>Queries.list({ page: 1 }));
  const createMutation = useCreate<Resource>();
  const deleteMutation = useDelete<Resource>();
  // ...
}
```
