---
name: react-build
description: |
  Build tooling and TypeScript configuration for React projects with JS and TS.
  Covers Vite (vite.config.ts, plugins, aliases, env variables, proxy, build
  optimization, library mode), TypeScript configuration (tsconfig.json, strict mode,
  path aliases, utility types, generics, type guards, discriminated unions, branded
  types, declaration files), and project structure best practices.

  USE WHEN: user mentions "Vite", "vite.config", "HMR", "build config", "TypeScript",
  "tsconfig", "tsconfig.json", "strict mode", "path aliases", "type guards",
  "utility types", "generics", "discriminated unions", "branded types", "declaration files",
  "VITE_ env", "@/ alias", "build optimization", "library mode", "rollup",
  asks about "project setup", "TypeScript errors", "tsconfig options"

  DO NOT USE FOR: testing config — use react-dev-suite:react-testing,
  new project scaffold — use react-dev-suite:react-new-project
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React Build Tools & TypeScript — Vite + TS

---

## Vite Configuration

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app && npm install
```

### Full vite.config.ts

```ts
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');

  return {
    plugins: [
      react({
        babel: {
          plugins: ['@babel/plugin-proposal-decorators'],  // optional
        },
      }),
    ],

    resolve: {
      alias: {
        '@':          path.resolve(__dirname, './src'),
        '@components': path.resolve(__dirname, './src/components'),
        '@hooks':     path.resolve(__dirname, './src/hooks'),
        '@pages':     path.resolve(__dirname, './src/pages'),
        '@services':  path.resolve(__dirname, './src/services'),
        '@types':     path.resolve(__dirname, './src/types'),
        '@utils':     path.resolve(__dirname, './src/utils'),
      },
    },

    server: {
      port: 3000,
      open: true,
      proxy: {
        '/api': {
          target: env.VITE_API_URL || 'http://localhost:8080',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },

    build: {
      target: 'es2020',
      outDir: 'dist',
      sourcemap: true,
      rollupOptions: {
        output: {
          manualChunks: {
            'react-vendor':  ['react', 'react-dom'],
            'router-vendor': ['react-router-dom'],
            'query-vendor':  ['@tanstack/react-query'],
          },
        },
      },
    },
  };
});
```

### Environment Variables

```bash
# .env
VITE_API_URL=http://localhost:8080
VITE_APP_NAME=My App

# .env.production
VITE_API_URL=https://api.myapp.com

# .env.local   (gitignored)
VITE_SECRET_KEY=dev-only-key
```

```ts
// src/config.ts — typed env access
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_APP_NAME: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

export const config = {
  apiUrl:  import.meta.env.VITE_API_URL,
  appName: import.meta.env.VITE_APP_NAME,
};
```

---

## TypeScript Configuration

### Recommended tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",

    /* Strict — always enable */
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,

    /* Module resolution */
    "resolveJsonModule": true,
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "noEmit": true,

    /* Path aliases — match vite.config.ts */
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@pages/*": ["./src/pages/*"],
      "@services/*": ["./src/services/*"],
      "@types/*": ["./src/types/*"],
      "@utils/*": ["./src/utils/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

---

## TypeScript Patterns for React

### Utility Types

```ts
// Partial — all fields optional
type UpdateUser = Partial<User>;

// Required — all fields required
type RequiredConfig = Required<Config>;

// Pick — subset of fields
type UserPreview = Pick<User, 'id' | 'name' | 'avatar'>;

// Omit — exclude fields
type CreateUser = Omit<User, 'id' | 'createdAt'>;

// Record — key/value mapping
type PermissionMap = Record<UserRole, Permission[]>;

// ReturnType — extract function return type
type QueryResult = ReturnType<typeof useQuery>;

// Parameters — extract function params
type SubmitParams = Parameters<typeof handleSubmit>[0];

// NonNullable — remove null/undefined
type RequiredId = NonNullable<User['id']>;
```

### Generics

```ts
// Generic API response wrapper
interface ApiResponse<T> {
  data: T;
  error: string | null;
  meta?: { total: number; page: number };
}

// Generic hook return type
function useFetch<T>(url: string): {
  data: T | null;
  loading: boolean;
  error: Error | null;
} { /* ... */ }

// Constrained generics
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Generic React component
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return <ul>{items.map((item, i) => <li key={keyExtractor(item)}>{renderItem(item, i)}</li>)}</ul>;
}
```

### Type Guards

```ts
// Narrowing with type predicates
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value
  );
}

// Discriminated union
type ApiState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function renderState<T>(state: ApiState<T>) {
  switch (state.status) {
    case 'loading': return <Spinner />;
    case 'error':   return <Alert>{state.error.message}</Alert>;
    case 'success': return <div>{JSON.stringify(state.data)}</div>;
    default:        return null;
  }
}
```

### Branded Types (Prevent ID Mixing)

```ts
type UserId    = string & { readonly _brand: 'UserId' };
type ProductId = string & { readonly _brand: 'ProductId' };

function createUserId(id: string): UserId {
  return id as UserId;
}

// TypeScript error: ProductId ≠ UserId
function getUser(id: UserId): Promise<User> { /* ... */ }
const productId = createProductId('p-1');
getUser(productId);  // ❌ Type error caught at compile time
```

---

## Project Structure

```
src/
├── app/              ← providers, router root
├── pages/            ← route-level components
├── features/         ← feature modules (co-locate components, hooks, services)
│   ├── users/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── types.ts
│   └── products/
├── components/       ← shared UI components
│   └── ui/           ← primitive components (Button, Input, etc.)
├── hooks/            ← shared custom hooks
├── services/         ← API clients, external services
├── stores/           ← Zustand / Redux stores
├── utils/            ← pure utility functions
├── types/            ← global TypeScript types
└── test/             ← test setup, utils, mocks
```

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| `any` type | Use `unknown` and narrow, or proper generics |
| Barrel index.ts with heavy re-exports | Direct imports — barrel files hurt tree shaking |
| Missing `allowImportingTsExtensions` | Add to tsconfig when using `.ts` extensions in imports |
| `tsconfig.json` without `strict: true` | Always enable strict — catches real bugs |
| Non-null assertion `!` everywhere | Proper null checks or `??` operator |
| Hardcoded API base URL in components | Use `config.ts` with `import.meta.env` |
