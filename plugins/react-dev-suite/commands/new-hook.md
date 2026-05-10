---
description: Generate a typed custom React hook with tests. Usage: /react-dev-suite:new-hook <hookName> [category: data|state|ui|async|event]
---

Generate a complete, typed custom React hook based on: $ARGUMENTS

## Instructions

Parse the arguments:
- **hookName** — camelCase starting with `use` (if user omits `use`, prepend it)
- **category** — determines the hook template (default: auto-detect from name)
  - `data` — fetches or manages remote data (useUsers, useProduct…)
  - `state` — manages local/derived state (useToggle, useCounter, useLocalStorage…)
  - `ui` — interacts with DOM/browser (useMediaQuery, useIntersectionObserver, useDebounce…)
  - `async` — wraps async operations (useAsync, useRequest…)
  - `event` — subscribes to events (useEventListener, useKeyPress…)

## What to generate

### 1. Hook file — `src/hooks/<hookName>.ts`

Requirements:
- Fully typed with TypeScript generics where appropriate
- Correct dependency arrays in all `useEffect` / `useMemo` / `useCallback`
- Cleanup functions for all subscriptions, timers, event listeners
- Return tuple or named object (prefer named object for > 2 values)
- JSDoc comment on the hook function explaining params and return value

### 2. Test file — `src/hooks/<hookName>.test.ts`

Requirements:
- Use `renderHook` from `@testing-library/react`
- Use `act` for state-changing calls
- Test: initial state, main behavior, cleanup (verify no memory leaks), edge cases
- Wrap with any required providers if the hook uses Context

## Templates by category

### `state` — useLocalStorage example
```ts
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialValue;
    } catch { return initialValue; }
  });

  const set = useCallback((val: T | ((prev: T) => T)) => {
    setValue(prev => {
      const next = typeof val === 'function' ? (val as (p: T) => T)(prev) : val;
      localStorage.setItem(key, JSON.stringify(next));
      return next;
    });
  }, [key]);

  const remove = useCallback(() => {
    localStorage.removeItem(key);
    setValue(initialValue);
  }, [key, initialValue]);

  return { value, set, remove } as const;
}
```

### `ui` — useDebounce example
```ts
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState<T>(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);  // cleanup on every change
  }, [value, delay]);
  return debounced;
}
```

### `event` — useEventListener example
```ts
function useEventListener<K extends keyof WindowEventMap>(
  eventName: K,
  handler: (event: WindowEventMap[K]) => void,
  element: EventTarget = window
) {
  const savedHandler = useRef(handler);
  useLayoutEffect(() => { savedHandler.current = handler; }, [handler]);

  useEffect(() => {
    const listener = (e: Event) => savedHandler.current(e as WindowEventMap[K]);
    element.addEventListener(eventName, listener);
    return () => element.removeEventListener(eventName, listener);
  }, [eventName, element]);
}
```

### `data` — useResource example
```ts
function use<Resource>(queryKey: string[], queryFn: () => Promise<Resource>) {
  return useQuery({ queryKey, queryFn });
}
```

### `async` — useAsync example
```ts
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'pending' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function useAsync<T>(asyncFn: () => Promise<T>, immediate = false) {
  const [state, setState] = useState<AsyncState<T>>({ status: 'idle' });

  const execute = useCallback(async () => {
    setState({ status: 'pending' });
    try {
      const data = await asyncFn();
      setState({ status: 'success', data });
    } catch (err) {
      setState({ status: 'error', error: err as Error });
    }
  }, [asyncFn]);

  useEffect(() => { if (immediate) execute(); }, [execute, immediate]);
  return { ...state, execute };
}
```

## After generating

- Add export to `src/hooks/index.ts` if it exists
- Confirm: "Generated `$hookName` in `src/hooks/<hookName>.ts`. Import with: `import { <hookName> } from '@/hooks/<hookName>'`"
