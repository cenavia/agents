---
name: react-state
description: |
  State management in React projects with JS and TS. Covers React Context API
  (createContext, useContext, Provider patterns, performance optimization),
  Zustand (stores, slices, devtools, persist), and Redux Toolkit (createSlice,
  createAsyncThunk, RTK Query, configureStore). Guides choosing the right tool
  for the scale of the project.

  USE WHEN: user mentions "state management", "Context API", "useContext",
  "createContext", "Zustand", "Redux", "Redux Toolkit", "RTK Query",
  "global state", "shared state", "store", "slice", "createSlice",
  "zustand store", "persist state", asks about "prop drilling", "state sharing"

  DO NOT USE FOR: local component state — use react-dev-suite:react-core,
  server/async state — use react-dev-suite:react-data
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React State Management — JS & TS

---

## Decision Guide

| Scale | Tool | Why |
|---|---|---|
| Small app / feature scope | **Context API** | Zero deps, built-in, simple |
| Medium app, frequent updates | **Zustand** | Minimal boilerplate, no providers, devtools |
| Large app, complex async flows | **Redux Toolkit** | Predictable, RTK Query, great devtools |

---

## Context API

```tsx
// 1. Define context with TypeScript — always include a default guard
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

// 2. Provider with co-located state
export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  const toggleTheme = useCallback(() => {
    setTheme(prev => (prev === 'light' ? 'dark' : 'light'));
  }, []);

  const value = useMemo(() => ({ theme, toggleTheme }), [theme, toggleTheme]);

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

// 3. Custom hook for safe consumption
export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used inside ThemeProvider');
  return ctx;
}

// 4. Consume
function Header() {
  const { theme, toggleTheme } = useTheme();
  return <button onClick={toggleTheme}>Mode: {theme}</button>;
}
```

### Context Performance — Split by update frequency

```tsx
// Separate fast-changing values from stable callbacks
const UserDataContext  = createContext<UserData | null>(null);
const UserActionsContext = createContext<UserActions | null>(null);

// Components that only call actions won't re-render when data changes
function UserActions() {
  const actions = useContext(UserActionsContext)!;
  return <button onClick={actions.logout}>Logout</button>;
}
```

---

## Zustand

```bash
npm install zustand
```

### Basic Store (JS)

```js
import { create } from 'zustand';

const useCounterStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset:     () => set({ count: 0 }),
}));

// Usage
function Counter() {
  const { count, increment } = useCounterStore();
  return <button onClick={increment}>{count}</button>;
}
```

### Typed Store (TS)

```ts
import { create } from 'zustand';

interface User {
  id: string;
  name: string;
  email: string;
}

interface AuthStore {
  user: User | null;
  isLoading: boolean;
  login: (credentials: { email: string; password: string }) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  isLoading: false,

  login: async (credentials) => {
    set({ isLoading: true });
    try {
      const user = await authApi.login(credentials);
      set({ user, isLoading: false });
    } catch {
      set({ isLoading: false });
      throw new Error('Login failed');
    }
  },

  logout: () => set({ user: null }),
}));
```

### Zustand with Devtools + Persist

```ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

export const useSettingsStore = create<SettingsStore>()(
  devtools(
    persist(
      (set) => ({
        locale: 'en',
        colorScheme: 'light' as 'light' | 'dark',
        setLocale: (locale) => set({ locale }),
        setColorScheme: (colorScheme) => set({ colorScheme }),
      }),
      { name: 'app-settings' }  // localStorage key
    ),
    { name: 'SettingsStore' }   // devtools label
  )
);
```

### Slice Pattern (large stores)

```ts
// features/cart/cartSlice.ts
import { StateCreator } from 'zustand';

export interface CartSlice {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  clearCart: () => void;
}

export const createCartSlice: StateCreator<CartSlice> = (set) => ({
  items: [],
  addItem: (item) => set((s) => ({ items: [...s.items, item] })),
  removeItem: (id) => set((s) => ({ items: s.items.filter(i => i.id !== id) })),
  clearCart: () => set({ items: [] }),
});

// store.ts — combine slices
import { create } from 'zustand';
import { createCartSlice, CartSlice } from './features/cart/cartSlice';
import { createUserSlice, UserSlice } from './features/user/userSlice';

type AppStore = CartSlice & UserSlice;

export const useStore = create<AppStore>()((...args) => ({
  ...createCartSlice(...args),
  ...createUserSlice(...args),
}));
```

---

## Redux Toolkit

```bash
npm install @reduxjs/toolkit react-redux
```

### Slice + Store (TS)

```ts
// features/counter/counterSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CounterState {
  value: number;
  status: 'idle' | 'loading';
}

const counterSlice = createSlice({
  name: 'counter',
  initialState: { value: 0, status: 'idle' } as CounterState,
  reducers: {
    increment: (state) => { state.value += 1; },         // Immer — direct mutation OK
    decrement: (state) => { state.value -= 1; },
    setValue:  (state, action: PayloadAction<number>) => { state.value = action.payload; },
  },
});

export const { increment, decrement, setValue } = counterSlice.actions;
export default counterSlice.reducer;

// store.ts
import { configureStore } from '@reduxjs/toolkit';
import counterReducer from './features/counter/counterSlice';

export const store = configureStore({
  reducer: { counter: counterReducer },
});

export type RootState   = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// hooks.ts — typed hooks
import { useDispatch, useSelector, TypedUseSelectorHook } from 'react-redux';
export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

### Async Thunk

```ts
import { createAsyncThunk } from '@reduxjs/toolkit';

export const fetchUser = createAsyncThunk(
  'users/fetchById',
  async (userId: string, { rejectWithValue }) => {
    try {
      return await usersApi.getById(userId);
    } catch (error) {
      return rejectWithValue((error as Error).message);
    }
  }
);

// In slice — handle lifecycle
extraReducers: (builder) => {
  builder
    .addCase(fetchUser.pending,   (state) => { state.status = 'loading'; })
    .addCase(fetchUser.fulfilled, (state, action) => {
      state.status = 'idle';
      state.user = action.payload;
    })
    .addCase(fetchUser.rejected, (state, action) => {
      state.status = 'idle';
      state.error = action.payload as string;
    });
},
```

### RTK Query

```ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const usersApi = createApi({
  reducerPath: 'usersApi',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  tagTypes: ['User'],
  endpoints: (builder) => ({
    getUsers:   builder.query<User[], void>({ query: () => '/users', providesTags: ['User'] }),
    getUserById: builder.query<User, string>({ query: (id) => `/users/${id}` }),
    createUser: builder.mutation<User, Partial<User>>({
      query: (body) => ({ url: '/users', method: 'POST', body }),
      invalidatesTags: ['User'],
    }),
  }),
});

export const { useGetUsersQuery, useGetUserByIdQuery, useCreateUserMutation } = usersApi;

// Component
function UserList() {
  const { data: users = [], isLoading, error } = useGetUsersQuery();
  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage />;
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

---

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Context value as new object every render | All consumers re-render | Wrap with `useMemo` |
| Single massive Context | Unrelated updates cause wide re-renders | Split into domain-specific contexts |
| Zustand selector without shallow | Triggers re-render on unrelated changes | Use `useShallow` or select primitives |
| `getState()` in React render | Bypasses reactivity | Use selector hook instead |
| Storing derived data in Redux | Sync issues, redundancy | Use `createSelector` (reselect) |
