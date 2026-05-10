---
description: Scaffold a complete React project from scratch — creates the directory, installs all dependencies, writes all config files, sets up testing infrastructure, and saves a .rds-context.json for subsequent commands. Usage: /react-dev-suite:new-project <project-name> [stack: modern|classic|minimal] [styling: tailwind|mui] [architecture: screaming|file-type|modular|atomic] [dir: ./path]
---

Scaffold a complete new React project based on: $ARGUMENTS

---

## Phase 0 — Gather requirements

Parse the arguments:
- **project-name** — kebab-case name (required). If not provided, ask.
- **stack** — technology stack (default: `modern`)
  - `modern` — React 19 + TanStack Router + TanStack Query + Zustand + RHF/Zod + Vitest
  - `classic` — React 18 + React Router v6 + TanStack Query + Zustand + RHF/Zod + Vitest
  - `minimal` — React 18 + React Router v6 + Axios + Vitest (no heavy state library)
- **styling** — CSS approach (default: `tailwind`)
  - `tailwind` — Tailwind CSS v4 + clsx + tailwind-merge + shadcn/ui ready
  - `mui` — Material UI v6 with cssVariables + colorSchemes
- **architecture** — folder structure pattern (default: `screaming`)
  - `screaming` — `src/features/<domain>/` + `src/shared/ui/` (recommended for most projects)
  - `file-type` — `src/components/` + `src/pages/<name>/` (simple, great for beginners)
  - `modular` — `src/features/<Domain>/` with `views/` + `pages/` subdirs (DDD-inspired)
  - `atomic` — components split into `atoms/molecules/organisms/templates/` layers
- **dir** — output directory (default: `./<project-name>`)

If `stack`, `styling`, or `architecture` are missing, present this menu and wait for the user's answer:

```
Which stack?
  A) modern  — React 19 · TanStack Router · TanStack Query · Zustand · RHF+Zod · Tailwind/MUI · Vitest (recommended)
  B) classic — React 18 · React Router v6 · TanStack Query · Zustand · RHF+Zod · Tailwind/MUI · Vitest
  C) minimal — React 18 · React Router v6 · Axios · Tailwind · Vitest

Which styling?
  1) Tailwind CSS v4 + shadcn/ui ready
  2) Material UI v6

Which architecture?
  I)   screaming  — src/features/<domain>/ + src/shared/ui/ (recommended)
  II)  file-type  — src/components/ + src/pages/<name>/
  III) modular    — src/features/<Domain>/views/ + pages/ (DDD)
  IV)  atomic     — atoms / molecules / organisms / templates
```

---

## Phase 1 — Execute scaffold

### Step 1 — Create Vite project

```bash
npm create vite@latest <project-name> -- --template react-ts
cd <project-name>
```

### Step 2 — Install dependencies

#### Stack: modern + styling: tailwind
```bash
npm install react@19 react-dom@19
npm install @tanstack/react-router @tanstack/react-query axios
npm install react-hook-form zod @hookform/resolvers
npm install zustand
npm install clsx tailwind-merge
npm install -D @tanstack/router-vite-plugin @tanstack/react-query-devtools
npm install -D tailwindcss @tailwindcss/vite
npm install -D vitest jsdom @vitest/coverage-v8
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
npm install -D jest-axe msw
npm install -D typescript-eslint eslint-plugin-react-hooks eslint-plugin-react-refresh
npm install -D @types/react@19 @types/react-dom@19
```

#### Stack: modern + styling: mui
```bash
npm install react@19 react-dom@19
npm install @tanstack/react-router @tanstack/react-query axios
npm install react-hook-form zod @hookform/resolvers
npm install zustand
npm install @mui/material @emotion/react @emotion/styled
npm install -D @tanstack/router-vite-plugin @tanstack/react-query-devtools
npm install -D vitest jsdom @vitest/coverage-v8
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
npm install -D jest-axe msw
npm install -D typescript-eslint eslint-plugin-react-hooks eslint-plugin-react-refresh
npm install -D @types/react@19 @types/react-dom@19
```

#### Stack: classic + styling: tailwind
```bash
npm install react-router-dom @tanstack/react-query axios
npm install react-hook-form zod @hookform/resolvers
npm install zustand
npm install clsx tailwind-merge
npm install -D @tanstack/react-query-devtools
npm install -D tailwindcss @tailwindcss/vite
npm install -D vitest jsdom @vitest/coverage-v8
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
npm install -D jest-axe msw
npm install -D typescript-eslint eslint-plugin-react-hooks eslint-plugin-react-refresh
```

#### Stack: classic + styling: mui
```bash
npm install react-router-dom @tanstack/react-query axios
npm install react-hook-form zod @hookform/resolvers
npm install zustand
npm install @mui/material @emotion/react @emotion/styled
npm install -D @tanstack/react-query-devtools
npm install -D vitest jsdom @vitest/coverage-v8
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
npm install -D jest-axe msw
npm install -D typescript-eslint eslint-plugin-react-hooks eslint-plugin-react-refresh
```

#### Stack: minimal
```bash
npm install react-router-dom axios
npm install clsx tailwind-merge
npm install -D tailwindcss @tailwindcss/vite
npm install -D vitest jsdom @vitest/coverage-v8
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
npm install -D jest-axe msw
```

### Step 3 — Initialize MSW

```bash
npx msw init public/ --save
```

### Step 4 — Create base folder structure

Create the initial `src/` directory tree based on the chosen architecture:

#### architecture: screaming (default)
```bash
mkdir -p src/features
mkdir -p src/shared/ui src/shared/hooks src/shared/types src/shared/utils src/shared/constants
mkdir -p src/app
```

#### architecture: file-type
```bash
mkdir -p src/components src/pages src/hooks src/contexts src/services src/utils src/routes
```

#### architecture: modular
```bash
mkdir -p src/features
mkdir -p src/shared/ui src/shared/hooks src/shared/types src/shared/utils
mkdir -p src/app
```

#### architecture: atomic
```bash
mkdir -p src/components/atoms src/components/molecules src/components/organisms src/components/templates
mkdir -p src/pages
mkdir -p src/features
mkdir -p src/shared/hooks src/shared/utils src/shared/types
```

---

## Phase 2 — Write configuration files

Create ALL of the following files, adapting content to chosen stack/styling:

### `vite.config.ts`

#### modern + tailwind
```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { TanStackRouterVite } from '@tanstack/router-vite-plugin';
import path from 'path';

export default defineConfig({
  plugins: [TanStackRouterVite(), react(), tailwindcss()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
  server: { port: 3000, proxy: { '/api': { target: 'http://localhost:8080', changeOrigin: true } } },
  test: { environment: 'jsdom', globals: true, setupFiles: './src/test/setup.ts' },
});
```

#### modern + mui
Same but without `tailwindcss()`.

#### classic (both stylings)
Same but without `TanStackRouterVite()`, and without `tailwindcss()` for mui.

### `tsconfig.json`
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "resolveJsonModule": true,
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "noEmit": true,
    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### `src/index.css`
#### tailwind
```css
@import "tailwindcss";
```
#### mui
```css
*, *::before, *::after { box-sizing: border-box; }
```

### `src/lib/api.ts`
```ts
import axios from 'axios';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? '/api',
  timeout: 10_000,
});

api.interceptors.request.use(config => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  res => res,
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  },
);
```

### `src/lib/utils.ts` (tailwind only)
```ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

### `src/main.tsx`

#### modern
```tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { RouterProvider, createRouter } from '@tanstack/react-router';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { routeTree } from './routeTree.gen';
import './index.css';

const router      = createRouter({ routeTree });
const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 5 * 60 * 1000, retry: 2 } },
});

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
      <ReactQueryDevtools />
    </QueryClientProvider>
  </StrictMode>,
);
```

#### classic
```tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import App from './App';
import './index.css';

const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 5 * 60 * 1000, retry: 2 } },
});

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <QueryClientProvider client={queryClient}>
        <App />
        <ReactQueryDevtools />
      </QueryClientProvider>
    </BrowserRouter>
  </StrictMode>,
);
```

### `src/test/setup.ts`
```ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach, beforeAll, afterAll } from 'vitest';
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => { cleanup(); server.resetHandlers(); });
afterAll(() => server.close());
```

### `src/test/utils.tsx`
```tsx
import { render, type RenderOptions } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactNode } from 'react';

function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
}

function AllProviders({ children }: { children: ReactNode }) {
  return (
    <QueryClientProvider client={createTestQueryClient()}>
      {children}
    </QueryClientProvider>
  );
}

function customRender(ui: React.ReactElement, options?: RenderOptions) {
  return render(ui, { wrapper: AllProviders, ...options });
}

export * from '@testing-library/react';
export { customRender as render };
```

### `src/test/mocks/handlers.ts`
```ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  // Add your API mock handlers here
  // Example:
  // http.get('/api/users', () => HttpResponse.json([])),
];
```

### `src/test/mocks/server.ts`
```ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

### `src/routes/__root.tsx` (modern/TanStack Router only)
```tsx
import { createRootRoute, Outlet } from '@tanstack/react-router';

export const Route = createRootRoute({
  component: () => <Outlet />,
});
```

### `src/routes/index.tsx` (modern/TanStack Router only)
```tsx
import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/')({
  component: () => <div><h1>Home</h1></div>,
});
```

### `.env`
```
VITE_API_URL=http://localhost:8080
```

### `.env.local` (gitignored — for local dev overrides)
```
# VITE_API_URL=http://localhost:3001
```

### `.gitignore` — add to existing
```
.env.local
.rds-context.json
```

### `package.json` scripts — patch to add
```json
"typecheck": "tsc --noEmit",
"lint": "eslint . --max-warnings 0",
"test": "vitest",
"test:ui": "vitest --ui",
"coverage": "vitest run --coverage"
```

---

## Phase 3 — Write `.rds-context.json`

Write this file at the **project root** (next to `package.json`). This file is read by all subsequent plugin commands (`from-story`, `new-feature`, `new-query`, etc.) so they generate compatible code without re-detecting.

```json
{
  "projectName": "<project-name>",
  "stack": "<modern|classic|minimal>",
  "routing": "<tanstack-router|react-router>",
  "stateLib": "<zustand|none>",
  "dataFetching": "<tanstack-query|axios>",
  "forms": "<rhf-zod|none>",
  "styling": "<tailwind|mui>",
  "architecture": "<screaming|file-type|modular|atomic>",
  "testing": "vitest-rtl",
  "srcDir": "src",
  "apiBaseUrl": "/api",
  "createdAt": "<ISO timestamp>"
}
```

Values per stack:
| Field | modern | classic | minimal |
|---|---|---|---|
| `routing` | `tanstack-router` | `react-router` | `react-router` |
| `stateLib` | `zustand` | `zustand` | `none` |
| `dataFetching` | `tanstack-query` | `tanstack-query` | `axios` |
| `forms` | `rhf-zod` | `rhf-zod` | `none` |
| `architecture` | user choice (default: `screaming`) | user choice (default: `screaming`) | user choice (default: `screaming`) |

---

## Phase 4 — Final verification

Run in sequence:
```bash
npm run typecheck
npm run lint
npm test -- --run
npm run build
```

Report the result of each command. If any fails, fix before reporting success.

---

## Phase 5 — Summary

Print:

```
✅ Project <project-name> created successfully

Stack:        <stack> + <styling>
Architecture: <screaming|file-type|modular|atomic>
Location:     <dir>

Project structure (screaming):
<dir>/
├── src/
│   ├── features/           ← domain features go here
│   ├── shared/
│   │   ├── ui/             ← shared UI components
│   │   ├── hooks/
│   │   ├── types/
│   │   └── utils/
│   ├── app/
│   ├── lib/api.ts
│   ├── lib/utils.ts        (tailwind only)
│   ├── routes/             (modern only)
│   ├── test/setup.ts
│   ├── test/utils.tsx
│   ├── test/mocks/
│   └── main.tsx
├── .env
├── .rds-context.json       ← plugin context (gitignored)
├── vite.config.ts
└── tsconfig.json

(For file-type: src/components/ + src/pages/ + src/hooks/ + src/services/)
(For modular:   src/features/<Domain>/views/ + pages/ + src/shared/)
(For atomic:    src/components/atoms/ + molecules/ + organisms/ + templates/)

Next steps:
  cd <dir>
  npm run dev

Add your first feature:
  /react-dev-suite:from-story <your user story>
```
