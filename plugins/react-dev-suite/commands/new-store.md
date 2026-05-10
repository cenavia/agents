---
description: Generate a typed Zustand store with devtools and optional persistence. Usage: /react-dev-suite:new-store <storeName> [fields: cart:CartItem[],total:number] [with: persist|immer|devtools]
---

Generate a complete, typed Zustand store based on: $ARGUMENTS

---

## Step 0 — Load project context

Read `.rds-context.json` from the current directory:
```bash
cat .rds-context.json 2>/dev/null
```
If found, use `stateLib`, `architecture`, and `srcDir`.
If not found, detect from `package.json` and infer `architecture` from the filesystem:

```bash
find src -maxdepth 3 -type d 2>/dev/null | sort | head -40
```

Use first match: `src/domain/`+`src/infrastructure/` → `hexagonal` | `src/components/atoms/` → `atomic` | `src/features/*/views/` → `modular` | `src/features/` → `screaming` | `src/pages/`+`src/components/` → `file-type`.

Output path adapts to architecture:
- `screaming` / `modular` / `atomic`: `src/features/<storeName>/store.ts` (feature-scoped) or `src/shared/` (global store)
- `file-type`: `src/hooks/use<StoreName>Store.ts` or `src/contexts/<StoreName>Context.tsx`
- `hexagonal`: `src/infrastructure/` (state adapters)

**Rule:** Never propose restructuring to a different architecture. Adapt silently to what already exists.

Key adaptation:
- `stateLib: none` → warn the user: "This project doesn't use Zustand. Generate a Context + useReducer pattern instead?" and wait for confirmation before proceeding.
- `stateLib: zustand` → generate standard Zustand store (proceed normally).

---

## Instructions

Parse the arguments:
- **storeName** — camelCase (e.g. `cart`, `auth`, `ui`, `appSettings`)
- **fields** — comma-separated state field definitions: `<name>:<type>`
  - Examples: `user:User|null`, `items:CartItem[]`, `theme:light|dark`, `count:number`, `isOpen:boolean`
- **with** — comma-separated middleware (default: `devtools`)
  - `devtools` — Redux DevTools integration
  - `persist` — localStorage persistence via zustand/middleware
  - `immer` — Immer for mutable-style state updates

## What to generate

### 1. Store types — inline or in `src/stores/types.ts` if it exists

```ts
// Infer types from fields. For common domains, add likely fields:
// auth: User | null, isAuthenticated, token
// cart: items[], total, itemCount
// ui: theme, sidebar, modals
// settings: locale, colorScheme, notifications
```

### 2. Store file — `src/stores/use<StoreName>Store.ts`

#### With devtools only (default)
```ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface <StoreName>State {
  // state fields
  // actions
}

export const use<StoreName>Store = create<<StoreName>State>()(
  devtools(
    (set, get) => ({
      // initial state
      // actions using set() and get()
    }),
    { name: '<StoreName>Store' }
  )
);
```

#### With persist
```ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

export const use<StoreName>Store = create<<StoreName>State>()(
  devtools(
    persist(
      (set, get) => ({
        // state + actions
      }),
      {
        name: '<storeName>-storage',          // localStorage key
        partialize: (state) => ({             // only persist specific fields
          // list fields to persist (exclude session-only data)
        }),
      }
    ),
    { name: '<StoreName>Store' }
  )
);
```

#### With immer
```ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

export const use<StoreName>Store = create<<StoreName>State>()(
  devtools(
    immer((set) => ({
      items: [] as Item[],
      addItem: (item: Item) => set((state) => {
        state.items.push(item);              // direct mutation — immer handles immutability
      }),
      removeItem: (id: string) => set((state) => {
        state.items = state.items.filter(i => i.id !== id);
      }),
    })),
    { name: '<StoreName>Store' }
  )
);
```

### 3. Selector hooks — exported from the same file

```ts
// Granular selectors prevent unnecessary re-renders
export const use<StoreName>Count  = () => use<StoreName>Store(s => s.count);
export const use<StoreName>Actions = () => use<StoreName>Store(s => ({
  increment: s.increment,
  decrement: s.decrement,
  reset:     s.reset,
}));
```

### 4. Context for multiple instances (if the store represents per-feature state)

If storeName suggests per-instance state (e.g. `modal`, `accordion`, `wizard`), generate a context-based pattern instead:

```ts
import { createContext, useContext, useRef } from 'react';
import { createStore, useStore } from 'zustand';

// Factory — creates a fresh store per instance
function create<StoreName>Store(initial: Partial<<StoreName>State>) {
  return createStore<<StoreName>State>()(devtools((set) => ({
    ...defaultState,
    ...initial,
  })));
}

type <StoreName>StoreApi = ReturnType<typeof create<StoreName>Store>;
const <StoreName>Context = createContext<<StoreName>StoreApi | null>(null);

export function <StoreName>Provider({ children, ...initial }: React.PropsWithChildren<Partial<<StoreName>State>>) {
  const storeRef = useRef<<StoreName>StoreApi>();
  if (!storeRef.current) storeRef.current = create<StoreName>Store(initial);
  return <<StoreName>Context.Provider value={storeRef.current}>{children}</<StoreName>Context.Provider>;
}

export function use<StoreName>()<T>(selector: (s: <StoreName>State) => T) {
  const store = useContext(<StoreName>Context);
  if (!store) throw new Error('use<StoreName> must be inside <StoreName>Provider');
  return useStore(store, selector);
}
```

## Common store patterns to include

Based on storeName, include common actions:

**auth** → `login(credentials)`, `logout()`, `refreshToken()`, `setUser(user)`  
**cart** → `addItem(item)`, `removeItem(id)`, `updateQuantity(id, qty)`, `clearCart()`, computed `total`, `itemCount`  
**ui** → `setTheme(theme)`, `toggleSidebar()`, `openModal(id)`, `closeModal(id)`, `setLoading(key, bool)`  
**settings** → `setLocale(locale)`, `setColorScheme(scheme)`, `resetSettings()`

## After generating

Show usage examples:
```tsx
// Direct hook
const { items, addItem } = useCartStore();

// Granular selector (prevents re-render when other state changes)
const itemCount = useCartStoreCount();
```
