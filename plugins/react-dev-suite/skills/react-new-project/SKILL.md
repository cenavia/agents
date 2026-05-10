---
name: react-new-project
description: |
  Scaffold and configure new React projects with JS or TS from scratch. Provides
  opinionated project setup templates combining Vite, React 18/19, TypeScript,
  React Router or TanStack Router, TanStack Query, Zustand, React Hook Form + Zod,
  Tailwind CSS or Material UI, Vitest + React Testing Library, ESLint + TypeScript ESLint,
  and recommended project structure. Includes step-by-step commands and configuration.

  USE WHEN: user asks to "create a new React project", "scaffold a React app",
  "set up React with TypeScript", "start a React project", "initialize React",
  "new React + Tailwind project", "new React + MUI project", "React project template",
  asks about "recommended React stack", "React project structure", "what packages to use"

  DO NOT USE FOR: Next.js projects — use dedicated Next.js skills,
  existing project improvements — use specific skill areas
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# New React Project Setup — JS & TS

---

## Stack Options

### Option A — Modern Full Stack (Recommended for new projects)
**Vite + React 19 + TS + TanStack Router + TanStack Query + Zustand + RHF/Zod + Tailwind + Vitest**

### Option B — Classic Stack  
**Vite + React 18 + TS + React Router v6 + TanStack Query + Zustand + RHF/Zod + MUI + Vitest**

### Option C — Minimal JS
**Vite + React 18 + JS + React Router v6 + Axios + Tailwind + Vitest**

---

## Option A — Modern Full Stack Setup

### 1. Create Project

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app
```

### 2. Install All Dependencies

```bash
# Core
npm install react@19 react-dom@19

# Routing
npm install @tanstack/react-router
npm install -D @tanstack/router-vite-plugin

# Data fetching
npm install @tanstack/react-query axios
npm install -D @tanstack/react-query-devtools

# State management
npm install zustand

# Forms + validation
npm install react-hook-form zod @hookform/resolvers

# Styling
npm install tailwindcss @tailwindcss/vite clsx tailwind-merge

# Testing
npm install -D vitest jsdom @vitest/coverage-v8
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
npm install -D msw

# Linting
npm install -D eslint typescript-eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
npm install -D eslint-plugin-react-hooks eslint-plugin-react-refresh
```

### 3. vite.config.ts

```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { TanStackRouterVite } from '@tanstack/router-vite-plugin';
import path from 'path';

export default defineConfig({
  plugins: [
    TanStackRouterVite(),
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
  server: {
    port: 3000,
    proxy: { '/api': { target: 'http://localhost:8080', changeOrigin: true } },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.ts',
  },
});
```

### 4. Project Structure

```
src/
├── routes/                    ← TanStack Router file-based routes
│   ├── __root.tsx             ← root layout
│   ├── index.tsx              ← "/"
│   └── dashboard/
│       ├── route.tsx
│       └── index.tsx
├── features/                  ← feature modules
│   └── users/
│       ├── components/
│       ├── hooks/
│       ├── queries.ts          ← TanStack Query query objects
│       ├── services.ts         ← API calls
│       └── types.ts
├── components/
│   └── ui/                    ← primitive components
├── stores/                    ← Zustand stores
├── lib/
│   ├── api.ts                 ← Axios instance
│   └── utils.ts               ← cn() and helpers
├── test/
│   ├── setup.ts
│   ├── utils.tsx              ← custom render with providers
│   └── mocks/
│       ├── handlers.ts
│       └── server.ts
├── types/
│   └── api.ts
└── main.tsx
```

### 5. Core Files

```tsx
// src/main.tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { RouterProvider, createRouter } from '@tanstack/react-router';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { routeTree } from './routeTree.gen';   // auto-generated
import './index.css';

const router = createRouter({ routeTree });
const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 5 * 60 * 1000, retry: 2 } },
});

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
      <ReactQueryDevtools />
    </QueryClientProvider>
  </StrictMode>
);
```

```css
/* src/index.css */
@import "tailwindcss";
```

```ts
// src/lib/api.ts
import axios from 'axios';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? '/api',
  timeout: 10_000,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

```ts
// src/lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

### 6. TypeScript Config

```json
// tsconfig.json
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

### 7. package.json Scripts

```json
{
  "scripts": {
    "dev":      "vite",
    "build":    "tsc -b && vite build",
    "preview":  "vite preview",
    "test":     "vitest",
    "test:ui":  "vitest --ui",
    "coverage": "vitest run --coverage",
    "lint":     "eslint . --max-warnings 0",
    "typecheck": "tsc --noEmit"
  }
}
```

---

## Option B — Classic Stack (React Router + MUI)

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app

npm install react-router-dom @tanstack/react-query zustand
npm install react-hook-form zod @hookform/resolvers axios
npm install @mui/material @emotion/react @emotion/styled
npm install -D vitest jsdom @vitest/coverage-v8
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
npm install -D @tanstack/react-query-devtools
```

---

## Option C — Minimal JS

```bash
npm create vite@latest my-app -- --template react
cd my-app

npm install react-router-dom axios
npm install tailwindcss @tailwindcss/vite clsx tailwind-merge
npm install -D vitest jsdom @testing-library/react @testing-library/user-event
```

---

## Checklist After Scaffold

- [ ] `.env.local` created with `VITE_API_URL`
- [ ] `.gitignore` includes `.env.local`, `dist/`, `coverage/`
- [ ] `src/test/setup.ts` and `src/test/utils.tsx` created
- [ ] MSW initialized: `npx msw init public/ --save`
- [ ] ESLint config validated: `npm run lint`
- [ ] TypeScript compiles: `npm run typecheck`
- [ ] Tests run: `npm test`
- [ ] Dev server starts: `npm run dev`
