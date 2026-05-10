---
name: react-core
description: |
  Core React development with JS and TS. Covers React 18+, React 19 new APIs,
  functional components, hooks (useState, useEffect, useReducer, useRef, useMemo,
  useCallback, useContext), custom hooks, component patterns (compound, render props,
  HOC), concurrent features (useTransition, useDeferredValue, Suspense), and
  React 19 APIs (Actions, useActionState, useFormStatus, useOptimistic, use()).

  USE WHEN: user mentions "React component", "hooks", "useState", "useEffect",
  "useReducer", "custom hooks", "JSX", "React 18", "React 19", "useTransition",
  "useDeferredValue", "Suspense", "useActionState", "useFormStatus", "useOptimistic",
  "Server Actions", "ref as prop", "React Compiler", "Actions in React",
  asks about "component lifecycle", "React rendering", "concurrent features"

  DO NOT USE FOR: routing — use react-dev-suite:react-routing,
  state libraries — use react-dev-suite:react-state,
  performance tuning — use react-dev-suite:react-performance,
  testing — use react-dev-suite:react-testing
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React Core — JS & TS

> **Deep Knowledge**: Use `mcp__documentation__fetch_docs` with `technology: react` for full API docs.

---

## Functional Components

```tsx
// TypeScript — preferred pattern
interface UserCardProps {
  name: string;
  email: string;
  role?: 'admin' | 'user';
  onSelect: (id: string) => void;
  children?: React.ReactNode;
}

function UserCard({ name, email, role = 'user', onSelect, children }: UserCardProps) {
  return (
    <div className="card">
      <h2>{name}</h2>
      <p>{email}</p>
      <span>{role}</span>
      {children}
      <button onClick={() => onSelect(name)}>Select</button>
    </div>
  );
}
```

```jsx
// JavaScript — same pattern without types
function UserCard({ name, email, role = 'user', onSelect, children }) {
  return (
    <div className="card">
      <h2>{name}</h2>
      <button onClick={() => onSelect(name)}>Select</button>
      {children}
    </div>
  );
}
```

---

## State Hooks

```tsx
// useState — simple values
const [count, setCount] = useState(0);
const [user, setUser] = useState<User | null>(null);

// Functional update to avoid stale closure
setCount(prev => prev + 1);

// useReducer — complex/related state
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'reset'; payload: number };

function reducer(state: number, action: Action): number {
  switch (action.type) {
    case 'increment': return state + 1;
    case 'decrement': return state - 1;
    case 'reset':     return action.payload;
  }
}

const [count, dispatch] = useReducer(reducer, 0);
```

---

## Effect & Ref Hooks

```tsx
// useEffect — data fetching, subscriptions
useEffect(() => {
  const controller = new AbortController();
  fetchUser(id, { signal: controller.signal }).then(setUser);
  return () => controller.abort();   // cleanup
}, [id]);

// useRef — DOM access and mutable values without re-render
const inputRef = useRef<HTMLInputElement>(null);
const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

useEffect(() => {
  inputRef.current?.focus();
}, []);
```

---

## Performance Hooks

```tsx
// useMemo — expensive computation
const filtered = useMemo(
  () => items.filter(i => i.active && i.name.includes(query)),
  [items, query]
);

// useCallback — stable function reference for child props
const handleSelect = useCallback((id: string) => {
  setSelected(id);
}, []);  // empty deps → stable reference
```

---

## Custom Hooks

```tsx
// Pattern: extract stateful logic into reusable hooks
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setStoredValue = useCallback((val: T | ((prev: T) => T)) => {
    setValue(prev => {
      const next = typeof val === 'function' ? (val as (p: T) => T)(prev) : val;
      localStorage.setItem(key, JSON.stringify(next));
      return next;
    });
  }, [key]);

  return [value, setStoredValue] as const;
}

// Usage
const [theme, setTheme] = useLocalStorage<'light' | 'dark'>('theme', 'light');
```

---

## Component Patterns

### Compound Components
```tsx
// Parent controls shared state; children access via context
const TabsContext = createContext<{ active: string; setActive: (v: string) => void } | null>(null);

function Tabs({ children, defaultTab }: { children: React.ReactNode; defaultTab: string }) {
  const [active, setActive] = useState(defaultTab);
  return <TabsContext.Provider value={{ active, setActive }}>{children}</TabsContext.Provider>;
}

Tabs.Tab = function Tab({ value, children }: { value: string; children: React.ReactNode }) {
  const ctx = useContext(TabsContext)!;
  return (
    <button
      aria-selected={ctx.active === value}
      onClick={() => ctx.setActive(value)}
    >
      {children}
    </button>
  );
};

// Usage: <Tabs defaultTab="a"><Tabs.Tab value="a">A</Tabs.Tab></Tabs>
```

### Render Props
```tsx
function DataLoader<T>({
  fetch,
  render,
}: {
  fetch: () => Promise<T>;
  render: (data: T | null, loading: boolean) => React.ReactNode;
}) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch().then(d => { setData(d); setLoading(false); });
  }, [fetch]);

  return <>{render(data, loading)}</>;
}
```

---

## React 19 APIs

```tsx
// useActionState — async action with loading/error state
import { useActionState } from 'react';

function UpdateProfile() {
  const [state, action, isPending] = useActionState(
    async (prev: State, formData: FormData) => {
      const result = await updateProfile(formData);
      if (!result.ok) return { error: result.message };
      return { success: true };
    },
    { error: null }
  );

  return (
    <form action={action}>
      <input name="name" />
      <button disabled={isPending}>{isPending ? 'Saving…' : 'Save'}</button>
      {state.error && <p role="alert">{state.error}</p>}
    </form>
  );
}

// useOptimistic — instant UI feedback before server confirms
function LikeButton({ postId, initialLikes }: { postId: string; initialLikes: number }) {
  const [optimisticLikes, addOptimistic] = useOptimistic(
    initialLikes,
    (current, delta: number) => current + delta
  );

  async function handleLike() {
    addOptimistic(1);
    await likePost(postId);
  }

  return <button onClick={handleLike}>❤ {optimisticLikes}</button>;
}

// use() — read context or Promise in render
import { use } from 'react';

function UserName({ promise }: { promise: Promise<User> }) {
  const user = use(promise);   // suspends until resolved
  return <span>{user.name}</span>;
}

// Ref as prop (React 19 — no forwardRef needed)
function Input({ ref, ...props }: React.ComponentProps<'input'>) {
  return <input ref={ref} {...props} />;
}
```

---

## Concurrent Features (React 18+)

```tsx
// useTransition — mark state update as non-urgent
const [isPending, startTransition] = useTransition();

function handleSearch(value: string) {
  setInputValue(value);                    // urgent: update input immediately
  startTransition(() => setQuery(value));  // non-urgent: can be interrupted
}

// useDeferredValue — defer expensive re-renders
const deferredQuery = useDeferredValue(query);
const results = useMemo(() => expensiveFilter(items, deferredQuery), [items, deferredQuery]);

// Suspense — declarative loading state
<Suspense fallback={<Skeleton />}>
  <LazyComponent />
</Suspense>
```

---

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Mutating state directly | Skips re-render | Always return new object/array |
| useEffect for derived state | Causes extra render cycle | Compute during render with `useMemo` |
| Missing deps in useEffect | Stale closure bugs | Use ESLint `exhaustive-deps` rule |
| Inline object/array in JSX | New ref each render → child re-renders | Memoize with `useMemo` / move outside component |
| `key={index}` in dynamic lists | Wrong component reuse on reorder | Use stable, unique IDs as keys |

---

## Rules of Hooks

- Only call hooks at the **top level** (no conditions, loops, nested functions)
- Only call hooks in **React function components** or custom hooks
- Custom hook names must start with `use`
- ESLint plugin: `eslint-plugin-react-hooks` enforces these rules
