# react-dev-suite

**Professional React Development Plugin for Claude Code**

A comprehensive Claude Code plugin for building React applications in JavaScript and TypeScript. Provides **13 action commands**, 12 knowledge skills, and 3 specialized agents — covering the entire React development lifecycle from requirements to production-ready code.

---

## Quick Start

```bash
# Load locally
claude --plugin-dir /path/to/react-dev-suite

# Reload after changes (no restart needed)
/reload-plugins

# Validate the plugin manifest
claude plugin validate
```

---

## Complete Scaffold Workflow

The recommended flow when starting from zero — every command knows the project stack because `new-project` writes `.rds-context.json`.

```
┌─────────────────────────────────────────────────────────────────┐
│  1.  /react-dev-suite:new-project my-app                        │
│      → Runs npm create vite, installs deps, writes all config   │
│      → Writes .rds-context.json with the chosen stack           │
│                                                                  │
│  2.  /react-dev-suite:from-story <user story>                   │
│      → Reads .rds-context.json (Phase 0)                        │
│      → Parses story, shows plan, waits for confirmation         │
│      → Generates stack-compatible: feature, queries, store,     │
│        form, components, tests — in the correct order           │
│                                                                  │
│  3.  /react-dev-suite:from-story <next user story>              │
│      → Same context, another feature, zero re-detection         │
└─────────────────────────────────────────────────────────────────┘
```

### Full example

```bash
# Terminal
cd ~/projects
```

```
# Claude Code
/react-dev-suite:new-project shop-app stack:modern styling:tailwind

/react-dev-suite:from-story Como usuario quiero ver el catálogo de productos,
filtrar por categoría y precio, y agregar artículos al carrito.

/react-dev-suite:from-story El usuario puede ver su carrito, modificar cantidades
y proceder al checkout con su dirección de envío.

/react-dev-suite:from-story El admin puede gestionar el inventario: listar productos,
crear nuevos, editar precio y stock, y desactivar productos agotados.
```

Each `from-story` reads the same `.rds-context.json` — no re-detection, no stack mismatch, consistent code across all features.

---

## Commands

Commands are action-oriented — they **generate**, **audit**, or **transform** code.  
Invoke with `/react-dev-suite:<command> [arguments]`

---

### `new-project` — Create a project from scratch ⭐

**Usage:**
```
/react-dev-suite:new-project <project-name> [stack: modern|classic|minimal] [styling: tailwind|mui] [dir: ./path]
```

If `stack` or `styling` are not provided, the command shows an interactive menu and waits for your choice.

**What it does — in order:**

| Phase | Action |
|---|---|
| 0 | Shows interactive stack/styling menu if args are missing |
| 1 | Runs `npm create vite@latest <name> -- --template react-ts` |
| 2 | Installs all dependencies for the chosen stack |
| 3 | Runs `npx msw init public/ --save` |
| 4 | Writes all config files (vite.config.ts, tsconfig.json, main.tsx, index.css, lib/api.ts, lib/utils.ts, test/setup.ts, test/utils.tsx, test/mocks/, .env, .gitignore) |
| 5 | Writes **`.rds-context.json`** at the project root — consumed by all subsequent commands |
| 6 | Runs `typecheck`, `lint`, `test --run`, `build` and reports results |

**Stack options:**

| Stack | React | Router | State | Data | Forms |
|---|---|---|---|---|---|
| `modern` | 19 | TanStack Router | Zustand | TanStack Query | RHF + Zod |
| `classic` | 18 | React Router v6 | Zustand | TanStack Query | RHF + Zod |
| `minimal` | 18 | React Router v6 | — | Axios | — |

**`.rds-context.json` written:**
```json
{
  "projectName": "shop-app",
  "stack": "modern",
  "routing": "tanstack-router",
  "stateLib": "zustand",
  "dataFetching": "tanstack-query",
  "forms": "rhf-zod",
  "styling": "tailwind",
  "testing": "vitest-rtl",
  "srcDir": "src",
  "apiBaseUrl": "/api"
}
```

**Examples:**
```
/react-dev-suite:new-project shop-app
/react-dev-suite:new-project admin-panel stack:modern styling:mui
/react-dev-suite:new-project landing-page stack:minimal styling:tailwind
/react-dev-suite:new-project dashboard stack:classic styling:tailwind dir:./apps/web
```

---

### `from-story` — Start from a requirement or user story ⭐

**Usage:**
```
/react-dev-suite:from-story <user story or requirement text>
```

**The entry point for requirement-driven development.** Pass any user story, feature description, or requirement text. The command will:

1. **Parse** — extract entities, actions, UI surfaces, data flows, and business rules
2. **Plan** — produce a structured implementation table showing exactly which commands will run
3. **Confirm** — ask for approval before generating anything
4. **Execute** — run commands in the correct dependency order (types → data layer → state → forms → components → tests)
5. **Summarize** — provide an integration checklist and entry point code snippets

**Examples:**
```
/react-dev-suite:from-story As a user, I want to browse products by category,
add them to a cart, and proceed to checkout with my shipping address.

/react-dev-suite:from-story The admin needs a dashboard to manage registered users:
view the full list, search by name or email, edit roles, and deactivate accounts.

/react-dev-suite:from-story Build a comment system where authenticated users can
post comments on articles, reply to others, and delete their own comments.

/react-dev-suite:from-story Create a notification center that shows real-time
notifications via SSE, allows marking as read, and persists read state.
```

> **Tip:** This command orchestrates all other generation commands. For a single story it may invoke `new-feature`, `new-query`, `new-store`, `new-form`, `new-component`, and `gen-tests` in sequence.

---

### `new-component` — Generate a React component

**Usage:**
```
/react-dev-suite:new-component <ComponentName> [variant: fc|forwardRef|compound] [style: tailwind|mui|css-module]
```

**What it generates:**
- `src/components/<ComponentName>/<ComponentName>.tsx` — typed component with a11y attributes
- `src/components/<ComponentName>/index.ts` — barrel export
- `src/components/<ComponentName>/<ComponentName>.test.tsx` — Vitest + RTL tests
- `src/components/<ComponentName>/<ComponentName>.stories.tsx` — Storybook stories (if detected)

**Variants:**
| Variant | Description |
|---|---|
| `fc` | Standard functional component (default) |
| `forwardRef` | Forwards ref to DOM element — for inputs, primitives |
| `compound` | Compound component with sub-components via Context — tabs, menus, accordions |

**Examples:**
```
/react-dev-suite:new-component Button variant:fc style:tailwind
/react-dev-suite:new-component TextInput variant:forwardRef style:tailwind
/react-dev-suite:new-component Tabs variant:compound style:mui
/react-dev-suite:new-component Modal variant:compound style:tailwind
```

---

### `new-hook` — Generate a custom hook

**Usage:**
```
/react-dev-suite:new-hook <hookName> [category: data|state|ui|async|event]
```

**What it generates:**
- `src/hooks/<hookName>.ts` — typed hook with proper cleanup
- `src/hooks/<hookName>.test.ts` — tests with `renderHook` + `act`

**Categories:**
| Category | Templates | Examples |
|---|---|---|
| `state` | localStorage, sessionStorage, toggle, counter | `useLocalStorage`, `useToggle`, `useCounter` |
| `ui` | debounce, throttle, media query, intersection observer | `useDebounce`, `useMediaQuery`, `useScrollPosition` |
| `event` | event listener, keyboard, window resize | `useEventListener`, `useKeyPress`, `useOnline` |
| `async` | async state machine, request wrapper | `useAsync`, `useRequest` |
| `data` | wraps TanStack Query for a resource | `useUsers`, `useProduct` |

**Examples:**
```
/react-dev-suite:new-hook useDebounce category:ui
/react-dev-suite:new-hook useLocalStorage category:state
/react-dev-suite:new-hook useEventListener category:event
/react-dev-suite:new-hook useAsync category:async
/react-dev-suite:new-hook useUsers category:data
```

---

### `new-feature` — Scaffold a complete feature module

**Usage:**
```
/react-dev-suite:new-feature <featureName> [api-base: /endpoint] [with: store,router,form]
```

**What it generates:**
```
src/features/<featureName>/
├── components/
│   ├── <Feature>List.tsx
│   ├── <Feature>Card.tsx
│   ├── <Feature>Detail.tsx
│   └── <Feature>Form.tsx         (with: form)
├── hooks/
│   └── use<Feature>.ts
├── queries.ts                     TanStack Query query objects
├── services.ts                    Typed Axios service
├── store.ts                       Zustand slice (with: store)
├── routes.tsx                     Route definitions (with: router)
├── types.ts                       TypeScript interfaces
└── index.ts                       Public barrel exports
```

**Extras (`with:` flags):**
| Flag | Adds |
|---|---|
| `store` | Zustand store slice with devtools |
| `router` | Route files for detected routing library |
| `form` | Create/edit form with React Hook Form + Zod |

**Examples:**
```
/react-dev-suite:new-feature users api-base:/users
/react-dev-suite:new-feature products api-base:/products with:store,form
/react-dev-suite:new-feature auth api-base:/auth with:store,router,form
/react-dev-suite:new-feature dashboard with:store
```

---

### `new-form` — Generate a form with RHF + Zod

**Usage:**
```
/react-dev-suite:new-form <FormName> [fields: name:type,...] [variant: simple|multi-step|dialog]
```

**Field types:**
| Type | Zod Validator | HTML Input |
|---|---|---|
| `string` | `z.string().min(1)` | `text` |
| `email` | `z.string().email()` | `email` |
| `password` | `z.string().min(8).regex(...)` | `password` (+ confirm field auto-added) |
| `number` | `z.coerce.number()` | `number` |
| `boolean` | `z.boolean()` | `checkbox` |
| `date` | `z.string().date()` | `date` |
| `enum(a\|b)` | `z.enum(['a','b'])` | `select` |
| `tel` | `z.string().regex(...)` | `tel` |
| `url` | `z.string().url()` | `url` |
| `textarea` | `z.string().max(2000)` | `textarea` |
| `file` | `z.instanceof(File)` | `file` |
| `string[]` | `z.array(z.string())` | `useFieldArray` |

Append `?` for optional fields: `bio:textarea?`

**Variants:**
| Variant | Description |
|---|---|
| `simple` | Single-page form |
| `multi-step` | Wizard with per-step validation via `trigger()` |
| `dialog` | Form inside a modal/dialog |

**Examples:**
```
/react-dev-suite:new-form LoginForm fields:email:email,password:password
/react-dev-suite:new-form CreateUserForm fields:name:string,email:email,role:enum(admin|user),bio:textarea?
/react-dev-suite:new-form CheckoutForm fields:name:string,email:email,address:string,country:enum(US|MX|CO) variant:multi-step
/react-dev-suite:new-form ProfileForm fields:name:string,avatar:file?,website:url? variant:dialog
```

---

### `new-query` — Generate TanStack Query + Axios data layer

**Usage:**
```
/react-dev-suite:new-query <resourceName> [api-base: /endpoint] [operations: list,get,create,update,delete,infinite,search]
```

**What it generates:**
- `types.ts` — `Resource`, `CreateDto`, `UpdateDto`, `ListParams`, `ListResponse`
- `services.ts` — typed Axios service
- `queries.ts` — TanStack Query query objects with key factory
- `mutations.ts` — `useCreate<Resource>`, `useUpdate<Resource>`, `useDelete<Resource>`

**Operations:**
| Operation | Generates |
|---|---|
| `list` | `getAll()` + `queryOptions` with placeholderData |
| `get` | `getById()` + `queryOptions` with `enabled` guard |
| `create` | `create()` + `useCreate` mutation with `invalidateQueries` |
| `update` | `update()` + `useUpdate` mutation with optimistic cache update |
| `delete` | `remove()` + `useDelete` mutation |
| `infinite` | `infiniteQueryOptions` with `getNextPageParam` |
| `search` | Debounced search query |

**Examples:**
```
/react-dev-suite:new-query user api-base:/users
/react-dev-suite:new-query product api-base:/products operations:list,get,create,update,delete,infinite
/react-dev-suite:new-query post operations:list,get,create,delete
/react-dev-suite:new-query notification api-base:/notifications operations:list,infinite,delete
```

---

### `new-store` — Generate a Zustand store

**Usage:**
```
/react-dev-suite:new-store <storeName> [fields: field:type,...] [with: persist|immer|devtools]
```

**What it generates:**
- `src/stores/use<StoreName>Store.ts` — typed Zustand store
- Granular selector hooks to prevent unnecessary re-renders
- Context-based factory pattern (if per-instance store is needed)

**Middleware (`with:` flags):**
| Flag | Description |
|---|---|
| `devtools` | Redux DevTools integration (always included) |
| `persist` | localStorage persistence with `partialize` |
| `immer` | Mutable-style updates with Immer |

**Domain auto-completion** — for well-known store names, common actions are auto-generated:
- `auth` → `login`, `logout`, `refreshToken`, `setUser`
- `cart` → `addItem`, `removeItem`, `updateQuantity`, `clearCart`, computed `total`, `itemCount`
- `ui` → `setTheme`, `toggleSidebar`, `openModal`, `closeModal`, `setLoading`
- `settings` → `setLocale`, `setColorScheme`, `resetSettings`

**Examples:**
```
/react-dev-suite:new-store cart fields:items:CartItem[],total:number with:persist,immer
/react-dev-suite:new-store auth fields:user:User|null,token:string|null with:persist
/react-dev-suite:new-store ui fields:theme:light|dark,sidebarOpen:boolean with:persist
/react-dev-suite:new-store filters fields:category:string,priceRange:number[],tags:string[] with:immer
```

---

### `review` — Deep code review

**Usage:**
```
/react-dev-suite:review [file-path]
/react-dev-suite:review src/components/UserCard.tsx
/react-dev-suite:review src/features/auth/hooks/useAuth.ts
```

**Reviews for:**
- **Correctness** — Rules of Hooks, dependency arrays, stale closures, missing cleanup, state mutation
- **TypeScript** — `any` usage, non-null assertions, unsafe casts, missing return types
- **Performance** — inline objects as props, over-memoization, missing memoization, waterfall requests
- **Accessibility** — missing aria labels, clickable divs, form label associations, focus management
- **Security** — `dangerouslySetInnerHTML`, dynamic `href`/`src`, sensitive data in state
- **Maintainability** — component size, single responsibility, prop drilling, magic values

**Output:** Severity-coded issues (🔴 Critical / 🟡 Moderate / 🔵 Minor) with corrected code for each finding.

**Examples:**
```
/react-dev-suite:review
/react-dev-suite:review src/pages/Dashboard.tsx
/react-dev-suite:review src/components/forms/PaymentForm.tsx
/react-dev-suite:review src/hooks/useCartStore.ts
```

---

### `audit` — Full codebase audit

**Usage:**
```
/react-dev-suite:audit [target: react-19|react-18|all|a11y|perf|security]
```

Runs grep-based scans across the entire `src/` directory. Returns a report with counts, file locations, and recommended fixes.

**Targets:**
| Target | Scans For |
|---|---|
| `react-18` | `ReactDOM.render`, `ReactDOM.hydrate`, UNSAFE lifecycles |
| `react-19` | `createFactory`, `defaultProps`, `propTypes`, string refs, legacy context, `forwardRef`, old `act()` import |
| `a11y` | clickable divs, missing `alt`, missing labels, `tabIndex > 0`, `dangerouslySetInnerHTML` |
| `perf` | inline objects as props, `key={index}`, missing virtualization, Enzyme usage |
| `security` | unsanitized `dangerouslySetInnerHTML`, dynamic hrefs, hardcoded secrets |
| `all` | All of the above |

**Examples:**
```
/react-dev-suite:audit
/react-dev-suite:audit react-19
/react-dev-suite:audit a11y
/react-dev-suite:audit security
/react-dev-suite:audit all
```

---

### `gen-tests` — Generate Vitest + RTL tests

**Usage:**
```
/react-dev-suite:gen-tests <file-path> [coverage: unit|integration|full]
```

Reads the target file, analyzes its interface, and generates a complete test suite.

**Coverage levels:**
| Level | Generates |
|---|---|
| `unit` | Smoke test, props rendering, main interactions, error/empty states |
| `integration` | Unit + provider wrapping, MSW API mocking, routing integration |
| `full` | Integration + accessibility (axe) + edge cases + hook tests |

**Always included:** accessibility test with `jest-axe`.

**Examples:**
```
/react-dev-suite:gen-tests src/components/Button/Button.tsx
/react-dev-suite:gen-tests src/features/users/components/UserList.tsx coverage:integration
/react-dev-suite:gen-tests src/hooks/useAuth.ts
/react-dev-suite:gen-tests src/components/forms/LoginForm.tsx coverage:full
```

---

### `migrate` — Execute a React migration

**Usage:**
```
/react-dev-suite:migrate [target: 18|19|enzyme-to-rtl|string-refs|legacy-context|forwardRef]
```

Runs a pre-migration audit, presents a plan with file count and risk assessment, then executes the migration systematically — one file at a time, preserving behavior.

**Migration targets:**
| Target | Migrates |
|---|---|
| `18` | `ReactDOM.render` → `createRoot`, `ReactDOM.hydrate` → `hydrateRoot` |
| `19` | `createFactory`, `defaultProps` on fn components, `propTypes`, `act()` import, Context.Provider syntax |
| `enzyme-to-rtl` | All Enzyme tests to React Testing Library |
| `string-refs` | `ref="name"` + `this.refs.name` → `useRef`/`createRef` |
| `legacy-context` | `contextTypes`/`childContextTypes` → modern `createContext`/`useContext` |
| `forwardRef` | `forwardRef()` wrappers → React 19 ref-as-prop pattern |

**After migration:** runs `typecheck`, `test`, `lint`, `build` and reports results.

**Examples:**
```
/react-dev-suite:migrate 18
/react-dev-suite:migrate 19
/react-dev-suite:migrate enzyme-to-rtl
/react-dev-suite:migrate string-refs
/react-dev-suite:migrate legacy-context
/react-dev-suite:migrate forwardRef
```

---

### `perf-audit` — Performance audit

**Usage:**
```
/react-dev-suite:perf-audit [file-path or feature-name]
```

Analyzes a component or page for performance issues. Reads the target file and its direct children.

**Checks:**
- Inline objects/arrays as props causing unnecessary re-renders
- Inline callbacks defeating `React.memo`
- Context value not memoized
- Derived state stored in `useState` (should compute during render)
- Sequential `await` (waterfall) vs `Promise.all`
- Component-level waterfalls (parent fetches → child fetches)
- Missing `lazy()` on large components
- Long lists without virtualization
- Over- or under-memoization
- Non-tree-shakeable library imports

**Output:** Severity-coded findings with before/after code, plus React DevTools Profiler instructions for measurement.

**Examples:**
```
/react-dev-suite:perf-audit
/react-dev-suite:perf-audit src/pages/Dashboard.tsx
/react-dev-suite:perf-audit src/features/products/components/ProductList.tsx
/react-dev-suite:perf-audit src/contexts/AppContext.tsx
```

---

## Skills

Skills are knowledge references — they inject expert React guidance into the current context.  
Invoke with `/react-dev-suite:<skill>` to load the reference.

| Skill | Domain | Key Libraries/APIs |
|---|---|---|
| `react-core` | React 18/19, hooks, patterns, concurrent | React, useState, useEffect, useActionState, useOptimistic, use() |
| `react-state` | Global and local state management | Context API, Zustand, Redux Toolkit, RTK Query |
| `react-routing` | Client-side routing | React Router v6, TanStack Router |
| `react-data` | Data fetching and real-time | TanStack Query, Axios, SSE, WebSocket |
| `react-forms` | Forms and validation | React Hook Form, Zod, Yup |
| `react-styling` | Styling systems | Tailwind CSS, shadcn/ui, Material UI |
| `react-performance` | Optimization techniques | memo, virtualization, code splitting, Vercel rules |
| `react-testing` | Test tooling | Vitest, RTL, MSW, jest-axe, typescript-eslint |
| `react-ssr` | Server rendering | RSC, Server Actions, View Transitions API |
| `react-build` | Build tooling and TypeScript | Vite, tsconfig, generics, type guards |
| `react-migrate` | Version migrations | React 18/19 changes, Enzyme→RTL, grep audit commands |
| `react-new-project` | Project scaffolding | Full stack templates (Tailwind, MUI, Minimal JS) |

**Examples:**
```
/react-dev-suite:react-core
/react-dev-suite:react-forms
/react-dev-suite:react-migrate
/react-dev-suite:react-new-project
```

---

## Agents

Agents are specialized subagents with deep focus. Available via `/agents` or invoked automatically when context matches.

---

### `react-architect`

**Specialty:** Architecture design and stack selection.

**Invoked automatically when:** user asks about stack selection, project structure, scaling decisions, or architectural trade-offs.

**Capabilities:**
- Analyzes requirements and recommends the optimal React stack
- Designs folder structure and module boundaries
- Recommends state management strategy by scale
- Identifies coupling issues and scaling bottlenecks in existing code
- Compares React Router vs TanStack Router, Zustand vs Redux, Tailwind vs MUI

**Example triggers:**
```
"What stack should I use for this app?"
"How should I structure a large React monorepo?"
"Should I use Redux or Zustand for my e-commerce app?"
"Review my project structure and suggest improvements"
"How do I avoid prop drilling in this component hierarchy?"
```

---

### `react-migrator`

**Specialty:** React version upgrades and API migrations.

**Invoked automatically when:** user mentions migration, deprecated APIs, or React version upgrades.

**Capabilities:**
- Runs pre-migration grep audits to quantify work
- Creates a prioritized migration plan (blockers first)
- Migrates files systematically — one at a time, preserving behavior
- Handles all React 17→18→19 breaking changes
- Migrates Enzyme → React Testing Library
- Updates package dependencies to compatible versions

**Example triggers:**
```
"Migrate my app to React 19"
"I need to remove all Enzyme tests"
"Fix these UNSAFE_ lifecycle warnings"
"Migrate string refs across the codebase"
"How many files need to change for React 19?"
```

---

### `react-reviewer`

**Specialty:** Code quality review — correctness, a11y, security, performance.

**Invoked automatically when:** user asks to review code or asks about code quality.

**Capabilities:**
- Reviews hooks for stale closures, missing cleanup, wrong deps
- Finds TypeScript quality issues (`any`, unsafe assertions)
- Checks accessibility (aria attributes, keyboard nav, focus management)
- Identifies security risks (XSS, sensitive data exposure)
- Reviews performance (memoization, re-renders)
- Cannot write files — produces a review report only

**Example triggers:**
```
"Review this component"
"Is my useEffect correct?"
"Check this for accessibility issues"
"Is there any XSS risk in this code?"
"Code review for the auth flow"
```

---

## Worked Examples — `from-story`

The following examples show the **complete end-to-end flow**: user story input → parsed plan → files generated. The generated source code lives in [`examples/`](examples/).

---

### Example 1 — Order History with Filters and Cancellation

**Input story:**
```
/react-dev-suite:from-story Como usuario quiero ver el historial de mis pedidos,
filtrar por estado y cancelar los que están pendientes.
```

**Phase 1 — Parsed entities**

| Element | Extracted |
|---|---|
| Entity | `Order` (id, status, total, items, shippingAddress, createdAt) |
| Entity | `OrderItem`, `ShippingAddress` |
| Actions | browse list, filter by status, cancel (only when `pending`) |
| UI surfaces | list view with filters + pagination, cancel confirmation form |
| Data flows | GET `/orders?status=&page=`, PATCH `/orders/:id/cancel` |
| Business rule | Cancel button visible **only** for `status === 'pending'` |
| State needed | filter state (status, search, page) must survive re-renders |

**Phase 2 — Plan presented to user**

| # | Command | Arguments |
|---|---|---|
| 1 | `new-query` | `order api-base:/orders operations:list,get,infinite` |
| 2 | `new-store` | `orderFilters fields:status:OrderStatus?,search:string,page:number` |
| 3 | `new-form` | `CancelOrderForm fields:reason:textarea` |
| 4 | `new-component` | `OrderStatusBadge variant:fc style:tailwind` |
| 5 | `new-component` | `OrderList variant:fc style:tailwind` |
| 6 | `gen-tests` | `OrderList.tsx coverage:integration` |

**Phase 3 — Files generated** → [`examples/orders/src/features/orders/`](examples/orders/src/features/orders/)

```
src/features/orders/
├── types.ts                        Order, OrderItem, OrderStatus, CancelOrderDto
├── services.ts                     ordersService.getAll / getById / cancel
├── queries.ts                      orderQueries.list / detail / infinite
├── mutations.ts                    useCancelOrder()
├── store.ts                        useOrderFiltersStore + selectors
├── index.ts                        public barrel
└── components/
    ├── OrderStatusBadge.tsx        Color-coded status pill
    ├── CancelOrderForm.tsx         RHF + Zod form, reason textarea
    ├── OrderList.tsx               List + filters + pagination + cancel dialog
    └── OrderList.test.tsx          6 tests: loading, render, cancel button, filter, error, a11y
```

**Phase 4 — Integration**
```tsx
// In your router:
import { OrderList } from '@/features/orders';
<Route path="/orders" element={<OrderList />} />
```

---

### Example 2 — Admin User Management Dashboard

**Input story:**
```
/react-dev-suite:from-story El admin necesita un dashboard para gestionar usuarios
registrados: ver la lista completa, buscar por nombre o email, cambiar roles
(admin/editor/viewer) y desactivar cuentas.
```

**Phase 1 — Parsed entities**

| Element | Extracted |
|---|---|
| Entity | `User` (id, name, email, role, status, avatarUrl, lastLoginAt) |
| Actions | list all, search by name/email, filter by role/status, change role inline, deactivate/activate |
| UI surfaces | admin table with search bar, role/status filters, inline role select, action buttons per row |
| Data flows | GET `/users?search=&role=&status=&page=`, PATCH `/users/:id/role`, PATCH `/users/:id/deactivate`, PATCH `/users/:id/activate` |
| Business rule | Role edit is inline (click cell → select), not a modal |
| State needed | search + role + status + page filters |

**Phase 2 — Plan presented to user**

| # | Command | Arguments |
|---|---|---|
| 1 | `new-query` | `user api-base:/users operations:list,get` |
| 2 | `new-store` | `userFilters fields:search:string,role:UserRole?,status:UserStatus?,page:number` |
| 3 | `new-component` | `UserTable variant:fc style:tailwind` |
| 6 | `gen-tests` | `UserTable.tsx coverage:integration` |

**Phase 3 — Files generated** → [`examples/admin-users/src/features/users/`](examples/admin-users/src/features/users/)

```
src/features/users/
├── types.ts                        User, UserRole, UserStatus, UpdateUserRoleDto
├── services.ts                     usersService.getAll / getById / updateRole / deactivate / activate
├── queries.ts                      userQueries.list / detail
├── mutations.ts                    useUpdateUserRole / useDeactivateUser / useActivateUser
├── store.ts                        useUserFiltersStore + granular selectors
├── index.ts                        public barrel
└── components/
    ├── UserTable.tsx               Table + search/role/status filters + inline role edit + deactivate action
    └── UserTable.test.tsx          7 tests: render, count, deactivate buttons, role edit, mutation, error, a11y
```

**Phase 4 — Integration**
```tsx
// In your admin router (protected route):
import { UserTable } from '@/features/users';
<Route path="/admin/users" element={<ProtectedRoute role="admin"><UserTable /></ProtectedRoute>} />
```

---

## Typical Workflows

### From a requirement (recommended starting point)
```
/react-dev-suite:from-story As a user I want to manage my orders: view history,
filter by status, and cancel pending orders.
```
The command decomposes the story and orchestrates all generation steps automatically.

### Starting a new project
```
/react-dev-suite:react-new-project     ← choose a stack template
/react-dev-suite:from-story <user story for first feature>
```

### Building a feature manually (step by step)
```
/react-dev-suite:new-query product api-base:/products operations:list,get,create,update,delete
/react-dev-suite:new-store cart fields:items:CartItem[],total:number with:persist
/react-dev-suite:new-form CreateProductForm fields:name:string,price:number,category:enum(A|B|C)
/react-dev-suite:new-component ProductCard variant:fc style:tailwind
/react-dev-suite:gen-tests src/features/products/components/ProductCard.tsx coverage:full
```

### Pre-upgrade audit before React 19
```
/react-dev-suite:audit react-19
/react-dev-suite:migrate 19
```

### Code review workflow
```
/react-dev-suite:review src/features/checkout/CheckoutFlow.tsx
/react-dev-suite:perf-audit src/pages/Dashboard.tsx
/react-dev-suite:audit a11y
```

### Migrating from Enzyme to RTL
```
/react-dev-suite:audit react-18          ← confirm no other blockers
/react-dev-suite:migrate enzyme-to-rtl
/react-dev-suite:gen-tests src/components/UserCard.tsx coverage:full   ← fill gaps
```

---

## Installation

```bash
# Local (development/testing)
claude --plugin-dir /path/to/react-dev-suite

# Project scope (team)
claude plugin install react-dev-suite --scope project

# User scope (personal)
claude plugin install react-dev-suite
```

---

## Plugin Structure

```
react-dev-suite/
├── .claude-plugin/
│   └── plugin.json          ← manifest (name, version, author, paths)
├── commands/                ← 11 action commands
│   ├── new-component.md
│   ├── new-hook.md
│   ├── new-feature.md
│   ├── new-form.md
│   ├── new-query.md
│   ├── new-store.md
│   ├── review.md
│   ├── audit.md
│   ├── gen-tests.md
│   ├── migrate.md
│   └── perf-audit.md
├── skills/                  ← 12 knowledge skills
│   ├── react-core/
│   ├── react-state/
│   ├── react-routing/
│   ├── react-data/
│   ├── react-forms/
│   ├── react-styling/
│   ├── react-performance/
│   ├── react-testing/
│   ├── react-ssr/
│   ├── react-build/
│   ├── react-migrate/
│   └── react-new-project/
├── agents/                  ← 3 specialized agents
│   ├── react-architect.md
│   ├── react-migrator.md
│   └── react-reviewer.md
└── README.md
```

---

## Version History

| Version | Date | Changes |
|---|---|---|
| 1.1.0 | 2026-05-10 | Added 11 action commands + full README |
| 1.0.0 | 2026-05-10 | Initial release — 12 skills, 3 agents |

---

## License

MIT
