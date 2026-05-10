---
name: react-routing
description: |
  Client-side routing for React projects with JS and TS. Covers React Router v6+
  (BrowserRouter, Routes, Route, Link, useNavigate, useParams, useSearchParams,
  nested routes, layouts, protected routes, data loaders, error elements, lazy routes,
  code splitting) and TanStack Router (file-based routing, type-safe navigation,
  loaders, search params, authentication guards).

  USE WHEN: user mentions "React Router", "react-router-dom", "TanStack Router",
  "routing", "navigation", "useNavigate", "useParams", "useSearchParams",
  "nested routes", "protected routes", "route guards", "data loaders",
  "BrowserRouter", "HashRouter", "outlet", "file-based routing", "route types"

  DO NOT USE FOR: SSR routing in Next.js — use react-dev-suite:react-ssr,
  state management — use react-dev-suite:react-state
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React Routing — JS & TS

---

## React Router v6+

```bash
npm install react-router-dom
```

### Basic Setup

```tsx
// main.tsx
import { BrowserRouter } from 'react-router-dom';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
);

// App.tsx
import { Routes, Route } from 'react-router-dom';
import { lazy, Suspense } from 'react';

const Home      = lazy(() => import('./pages/Home'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const NotFound  = lazy(() => import('./pages/NotFound'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/" element={<RootLayout />}>
          <Route index element={<Home />} />
          <Route path="dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
    </Suspense>
  );
}
```

### Nested Routes + Layouts

```tsx
// layouts/RootLayout.tsx
import { Outlet, NavLink } from 'react-router-dom';

function RootLayout() {
  return (
    <>
      <nav>
        <NavLink to="/" end className={({ isActive }) => isActive ? 'active' : ''}>Home</NavLink>
        <NavLink to="/dashboard">Dashboard</NavLink>
      </nav>
      <main>
        <Outlet />  {/* renders matched child route */}
      </main>
    </>
  );
}
```

### Navigation Hooks

```tsx
// useNavigate — programmatic navigation
const navigate = useNavigate();
navigate('/dashboard');
navigate('/profile', { state: { from: 'login' } });
navigate(-1);  // back

// useParams — URL parameters
// Route: <Route path="users/:id" element={<UserDetail />} />
const { id } = useParams<{ id: string }>();

// useSearchParams — query strings (?page=2&sort=name)
const [searchParams, setSearchParams] = useSearchParams();
const page = Number(searchParams.get('page') ?? 1);
const updatePage = (n: number) => setSearchParams({ page: String(n) });

// useLocation — current location object
const location = useLocation();
const from = (location.state as { from?: string })?.from ?? '/';
```

### Protected Route Pattern

```tsx
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user } = useAuthStore();
  const location = useLocation();

  if (!user) {
    // Preserve the intended destination
    return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  }

  return <>{children}</>;
}
```

### Data Router (v6.4+) — Loaders & Actions

```tsx
import { createBrowserRouter, RouterProvider } from 'react-router-dom';

const router = createBrowserRouter([
  {
    path: '/',
    element: <RootLayout />,
    errorElement: <ErrorBoundary />,
    children: [
      {
        path: 'users',
        element: <UserList />,
        loader: async () => {
          const users = await fetchUsers();
          return { users };
        },
      },
      {
        path: 'users/:id',
        element: <UserDetail />,
        loader: async ({ params }) => {
          const user = await fetchUser(params.id!);
          if (!user) throw new Response('Not Found', { status: 404 });
          return { user };
        },
        action: async ({ request }) => {
          const formData = await request.formData();
          await updateUser(formData);
          return redirect('/users');
        },
      },
    ],
  },
]);

// Consume loader data
import { useLoaderData } from 'react-router-dom';

function UserDetail() {
  const { user } = useLoaderData() as { user: User };
  return <div>{user.name}</div>;
}

// App entry
function App() {
  return <RouterProvider router={router} />;
}
```

---

## TanStack Router

```bash
npm install @tanstack/react-router
npm install -D @tanstack/router-vite-plugin  # for file-based routing
```

### File-Based Routing (recommended)

```
src/routes/
├── __root.tsx        ← root layout + outlet
├── index.tsx         ← "/"
├── about.tsx         ← "/about"
├── dashboard/
│   ├── route.tsx     ← "/dashboard" layout
│   └── index.tsx     ← "/dashboard/"
└── users/
    ├── $userId.tsx   ← "/users/:userId"
    └── index.tsx     ← "/users"
```

```tsx
// src/routes/__root.tsx
import { createRootRoute, Outlet, Link } from '@tanstack/react-router';

export const Route = createRootRoute({
  component: () => (
    <>
      <nav>
        <Link to="/" activeProps={{ className: 'active' }}>Home</Link>
        <Link to="/dashboard">Dashboard</Link>
      </nav>
      <Outlet />
    </>
  ),
});

// src/routes/users/$userId.tsx
import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/users/$userId')({
  loader: async ({ params }) => {
    const user = await fetchUser(params.userId);
    return { user };
  },
  component: function UserDetail() {
    const { user } = Route.useLoaderData();
    const { userId } = Route.useParams();
    return <div>{user.name}</div>;
  },
});
```

### Type-Safe Navigation

```tsx
import { useNavigate, Link } from '@tanstack/react-router';

// navigate() is fully typed — TypeScript catches wrong paths/params
const navigate = useNavigate();
navigate({ to: '/users/$userId', params: { userId: '123' } });

// Link with search params
<Link to="/search" search={{ q: 'react', page: 1 }}>Search</Link>
```

### Search Params Validation

```tsx
import { createFileRoute } from '@tanstack/react-router';
import { z } from 'zod';

const searchSchema = z.object({
  page:  z.number().default(1),
  sort:  z.enum(['name', 'date']).default('name'),
  query: z.string().optional(),
});

export const Route = createFileRoute('/products')({
  validateSearch: searchSchema,
  component: function Products() {
    const { page, sort, query } = Route.useSearch();
    return <ProductList page={page} sort={sort} query={query} />;
  },
});
```

### Auth Guard Pattern

```tsx
import { createFileRoute, redirect } from '@tanstack/react-router';

export const Route = createFileRoute('/dashboard')({
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login', search: { redirect: '/dashboard' } });
    }
  },
  component: Dashboard,
});
```

---

## Quick Comparison

| Feature | React Router v6 | TanStack Router |
|---|---|---|
| Type safety | Partial (with types) | Full end-to-end TS |
| File-based routing | Plugin needed | Built-in |
| Search params | Basic | Validated + typed |
| Loaders/Actions | ✅ Data Router | ✅ Loaders |
| Bundle size | ~50 KB | ~35 KB |
| Maturity | Very mature | Stable v1+ |

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| `useEffect` + `navigate` for redirects | Use loader `redirect()` or `<Navigate>` |
| Hardcoded strings for routes | Create route constants or use TanStack's typed links |
| Fetching in component mount (waterfall) | Use route loaders to parallel-fetch |
| No `errorElement` on routes | Always add error boundaries at route level |
