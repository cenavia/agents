---
name: react-architecture
description: React project folder structure patterns — Screaming Architecture, file-type, modular/DDD, Atomic Design, and hexagonal. Decision guide, cross-module import rules, and when to use each pattern. Read this skill when placing files, scaffolding features, or auditing folder consistency.
---

# React Project Architecture Patterns

## Choosing an architecture

| Pattern | Best for | Complexity | Default? |
|---|---|---|---|
| **Screaming (feature-first)** | Most projects, medium-large apps | Medium | ✅ Yes |
| **File-type** | Small apps, prototypes, beginners | Low | — |
| **Modular / DDD** | Large apps with clear business domains | Medium-high | — |
| **Atomic Design** | Design system-heavy apps, component libraries | High | — |
| **Hexagonal** | Full-stack teams with ports/adapters backend | Very high | — |

---

## Screaming Architecture (recommended default)

Features "scream" the domain — `auth/`, `products/`, `orders/` are immediately visible at the top level. Each feature owns all its code and only exposes a public API via `index.ts`.

```
src/
├── features/
│   ├── auth/
│   │   ├── components/       ← components used only by this feature
│   │   ├── hooks/            ← hooks used only by this feature
│   │   ├── services.ts       ← API calls
│   │   ├── queries.ts        ← TanStack Query objects
│   │   ├── mutations.ts      ← useMutation hooks
│   │   ├── store.ts          ← Zustand slice (if applicable)
│   │   ├── types.ts          ← TypeScript interfaces
│   │   └── index.ts          ← public API (ONLY export from here)
│   └── products/
│       ├── components/
│       ├── services.ts
│       ├── queries.ts
│       ├── types.ts
│       └── index.ts
├── shared/
│   ├── ui/                   ← shared UI components (Button, Modal, Input, Badge)
│   ├── hooks/                ← shared hooks (useDebounce, useMediaQuery, useLocalStorage)
│   ├── types/                ← global TypeScript types and enums
│   ├── utils/                ← pure utility functions (cn, formatDate, formatCurrency)
│   └── constants/            ← app-wide constants
├── app/
│   ├── routes.tsx            ← all route definitions in one place
│   ├── App.tsx               ← root component
│   └── store.ts              ← QueryClient + root providers
└── main.tsx
```

**Rules:**
- Features import ONLY from `shared/` or their own files
- Feature A NEVER imports directly from Feature B
- When 2+ features need the same code → move it to `shared/`
- `index.ts` is the only public surface of each feature (barrel export)
- Components in `features/<name>/components/` are private to that feature

---

## File-type Structure

Groups files by technical role (components, hooks, services) rather than domain. Best for small apps or teams new to React. Scales poorly above ~10 pages.

```
src/
├── components/               ← shared, reusable components
│   ├── Button/
│   │   ├── Button.tsx
│   │   └── Button.test.tsx
│   ├── Avatar/
│   └── TextField/
├── pages/
│   ├── UserProfile/
│   │   ├── components/       ← components used only on this page
│   │   │   └── ProfileHeader/
│   │   ├── UserProfile.tsx
│   │   └── UserProfile.test.tsx
│   └── index.ts
├── hooks/                    ← all custom hooks
├── contexts/                 ← all React contexts
├── services/                 ← all API services
├── utils/
├── routes/
│   └── routes.tsx
└── App.tsx
```

**Rules:**
- Page-specific components live inside `pages/<PageName>/components/`
- Anything used by 2+ pages goes to top-level `components/`
- No `features/` directory — domain grouping is done by page

---

## Modular / DDD-inspired

Each module is a fully isolated vertical slice with its own views, pages, services, and state. Closest to Domain-Driven Design. Use when there are clear business boundaries and 5+ developers.

```
src/
├── features/
│   ├── Home/
│   │   ├── views/            ← pure presentational views (no data fetching)
│   │   │   └── HomeView.tsx
│   │   ├── pages/            ← smart containers (data fetching + state)
│   │   │   └── HomePage.tsx
│   │   ├── components/       ← feature-private components
│   │   ├── services/
│   │   ├── hooks/
│   │   ├── contexts/
│   │   └── index.ts
│   └── Orders/
│       ├── views/
│       ├── pages/
│       └── index.ts
├── shared/
│   └── ...                   ← same as Screaming Architecture
└── App.tsx
```

**Rules (stricter than Screaming):**
- Modules cannot import each other — only via `shared/` or an event/store bus
- `views/` = dumb presentation (no useQuery, no mutations)
- `pages/` = smart containers (useQuery, mutations, Zustand)
- Cross-module communication goes through Zustand stores in `shared/` or custom events

---

## Atomic Design

Components are categorized by their abstraction level. More than a folder structure — it's a design system methodology. Works best when the team has internalized the atom/molecule/organism hierarchy.

```
src/
├── components/
│   ├── atoms/                ← smallest, indivisible UI (Button, Icon, Badge, Input)
│   ├── molecules/            ← 2–3 atoms working together (SearchBar, FormField, Card)
│   ├── organisms/            ← complex reusable sections (ProductCard, NavBar, DataTable)
│   └── templates/            ← page skeletons with slot-based layouts (no real data)
├── pages/                    ← templates populated with real data
├── features/                 ← can be combined with Screaming for business logic
└── App.tsx
```

**Decision guide:**
- **Atom**: cannot be broken down further (Button, Icon, Spinner, Label)
- **Molecule**: 2–3 atoms with a single responsibility (SearchBar = Input + Button)
- **Organism**: complex UI section with multiple molecules (ProductCard, Header, Sidebar)
- **Template**: full page layout with slots — no real data, just structure
- **Page**: template + real data from queries/stores

**When to avoid:** When the team doesn't agree on what is an "atom" vs "molecule" — the categorization becomes a source of conflict rather than clarity.

---

## Hexagonal Architecture

Separates business logic (domain) from infrastructure (HTTP, UI, persistence). Use only if the backend uses the same pattern and the team is experienced with it.

```
src/
├── domain/
│   ├── models/               ← pure business entities (no framework dependencies)
│   │   └── User.ts
│   └── services/             ← business logic interfaces / use cases
│       └── UserService.ts
├── infrastructure/
│   ├── components/           ← React components (UI adapter)
│   │   ├── Avatar/
│   │   └── UserProfile/
│   ├── http/
│   │   ├── dto/              ← API data transfer objects
│   │   │   └── userDto.ts
│   │   └── http.ts           ← Axios instance
│   └── repositories/         ← implement domain service interfaces
│       └── UserRepository.ts
└── App.tsx
```

**When to use:** Only when the full-stack team is already using hexagonal/ports-adapters on the backend and wants to maintain conceptual consistency across layers.

---

## Cross-module import rules

Valid and invalid import patterns for Screaming and Modular architectures:

```
✅ features/auth          → shared/ui/Button
✅ features/auth          → features/auth/components/LoginForm
✅ features/products      → shared/hooks/useDebounce
✅ features/products      → shared/types/Pagination

❌ features/auth          → features/products/types    (cross-feature — use shared/)
❌ features/products      → features/cart/store        (cross-feature — use event bus or shared store)
❌ shared/ui/Button       → features/auth/types        (shared cannot import features)
```

---

## When to move code to shared/

Move to `shared/` when:
- **2 or more features** import the same component, hook, or type
- It has **no domain-specific business logic** (could exist without knowing what the app does)
- It would make sense as a **standalone design system component**
- It is a **utility** (pure function, formatter, constant)

Keep in `features/` when:
- **Only one feature** uses it — even if it looks "generic" today
- It contains **domain language** (OrderStatus, UserRole, ProductCategory)
- Extracting it would require passing too many domain-specific props

---

## Architecture field in .rds-context.json

All plugin commands read `architecture` from `.rds-context.json` to decide where to place generated files:

| `architecture` | Feature path | Shared components path |
|---|---|---|
| `screaming` | `src/features/<name>/` | `src/shared/ui/<Name>/` |
| `file-type` | `src/pages/<name>/` | `src/components/<Name>/` |
| `modular` | `src/features/<Name>/` with `views/` + `pages/` | `src/shared/ui/<Name>/` |
| `atomic` | `src/features/<name>/` with `atoms/molecules/organisms/` | `src/components/atoms/` or `molecules/` |
| `hexagonal` | `src/infrastructure/components/` | `src/domain/models/` |

---

## Detecting architecture from an existing project

When `.rds-context.json` is absent, detect the pattern from the filesystem before generating anything:

```bash
find src -maxdepth 3 -type d 2>/dev/null | sort | head -40
```

**Inference rules — first match wins:**

| Condition | Detected architecture |
|---|---|
| `src/domain/` AND `src/infrastructure/` exist | `hexagonal` |
| `src/components/atoms/` OR `src/components/molecules/` exist | `atomic` |
| `src/features/` exists AND any `src/features/*/views/` subdirectory found | `modular` |
| `src/features/` exists | `screaming` |
| `src/pages/` AND `src/components/` exist but NO `src/features/` | `file-type` |
| None of the above | Unknown — ask the user |

**Non-obvious cases:**
- A project may have `src/features/` but also `src/components/atoms/` → **atomic wins** (more specific)
- A project may have both `src/pages/` and `src/features/` → **screaming wins** (features take precedence)

---

## Critical behavioral rule

> **Always adapt to the project's existing architecture. Never propose migrating or refactoring to a different pattern unless the user explicitly requests it.**

If the user says "refactor to screaming" or "migrate my file-type project to features/", then proceed. Otherwise, generate all files following the detected or declared architecture — even if a different pattern would be "better" by some measure.

A project in the middle of development has context, conventions, and team agreements baked into its folder structure. Silently changing it causes merge conflicts, broken imports, and confusion. Respect what is already there.
