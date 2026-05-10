---
name: react-data
description: |
  Data fetching and real-time communication in React with JS and TS. Covers
  TanStack Query (useQuery, useMutation, QueryClient, caching, invalidation,
  optimistic updates, infinite queries), Axios (instances, interceptors,
  error handling), Server-Sent Events (SSE) for streaming, and WebSocket
  integration (custom hooks, Socket.IO, reconnection logic).

  USE WHEN: user mentions "TanStack Query", "React Query", "useQuery", "useMutation",
  "data fetching", "Axios", "HTTP requests", "interceptors", "server-sent events",
  "SSE", "EventSource", "WebSocket", "Socket.IO", "real-time", "streaming data",
  "API calls", "cache invalidation", "infinite scroll", asks about "async data"

  DO NOT USE FOR: server state in Next.js RSC — use react-dev-suite:react-ssr,
  forms/mutations — use react-dev-suite:react-forms,
  general state — use react-dev-suite:react-state
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React Data Fetching & Real-Time — JS & TS

---

## TanStack Query

```bash
npm install @tanstack/react-query
npm install -D @tanstack/react-query-devtools
```

### Setup

```tsx
// main.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,   // 5 min — data considered fresh
      gcTime:    10 * 60 * 1000,  // 10 min — cache retention
      retry: 2,
      refetchOnWindowFocus: true,
    },
  },
});

ReactDOM.createRoot(root).render(
  <QueryClientProvider client={queryClient}>
    <App />
    <ReactQueryDevtools initialIsOpen={false} />
  </QueryClientProvider>
);
```

### useQuery — Fetching Data

```tsx
import { useQuery } from '@tanstack/react-query';

// TypeScript: useQuery<TData, TError>
function UserProfile({ userId }: { userId: string }) {
  const {
    data: user,
    isLoading,
    isError,
    error,
    isFetching,  // background refetch indicator
  } = useQuery({
    queryKey: ['users', userId],   // cache key — array recommended
    queryFn: () => usersApi.getById(userId),
    enabled: !!userId,             // conditional fetching
  });

  if (isLoading) return <Skeleton />;
  if (isError)   return <Alert>{(error as Error).message}</Alert>;

  return (
    <div>
      {isFetching && <Spinner size="sm" />}
      <h1>{user!.name}</h1>
    </div>
  );
}
```

### useMutation — Creating / Updating Data

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query';

function CreatePost() {
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: (newPost: NewPost) => postsApi.create(newPost),
    onSuccess: () => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['posts'] });
    },
    onError: (error) => {
      toast.error((error as Error).message);
    },
  });

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      mutation.mutate({ title: 'New Post', body: '…' });
    }}>
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Saving…' : 'Create Post'}
      </button>
    </form>
  );
}
```

### Optimistic Updates

```tsx
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (updated) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] });
    const previous = queryClient.getQueryData<Todo[]>(['todos']);

    queryClient.setQueryData<Todo[]>(['todos'], (old = []) =>
      old.map(t => t.id === updated.id ? { ...t, ...updated } : t)
    );

    return { previous };   // context for rollback
  },
  onError: (_, __, context) => {
    queryClient.setQueryData(['todos'], context?.previous);
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] });
  },
});
```

### Infinite Queries (Pagination / Infinite Scroll)

```tsx
import { useInfiniteQuery } from '@tanstack/react-query';

const {
  data,
  fetchNextPage,
  hasNextPage,
  isFetchingNextPage,
} = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam = 1 }) => postsApi.getPage(pageParam),
  getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  initialPageParam: 1,
});

const allPosts = data?.pages.flatMap(page => page.items) ?? [];
```

### Query Factory Pattern (TS)

```ts
// queries/users.ts — centralise query key + fn
export const userQueries = {
  all:    ()         => ({ queryKey: ['users'] as const,           queryFn: usersApi.getAll }),
  detail: (id: string) => ({ queryKey: ['users', id] as const,    queryFn: () => usersApi.getById(id) }),
  posts:  (id: string) => ({ queryKey: ['users', id, 'posts'] as const, queryFn: () => usersApi.getPosts(id) }),
};

// Component
const { data } = useQuery(userQueries.detail(userId));
```

---

## Axios

```bash
npm install axios
```

### Instance + Interceptors

```ts
// lib/api.ts
import axios from 'axios';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10_000,
  headers: { 'Content-Type': 'application/json' },
});

// Attach auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Handle 401 globally
api.interceptors.response.use(
  (res) => res,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### Typed Service

```ts
// services/users.ts
import { api } from '../lib/api';

export interface User { id: string; name: string; email: string; }

export const usersApi = {
  getAll: ()             => api.get<User[]>('/users').then(r => r.data),
  getById: (id: string)  => api.get<User>(`/users/${id}`).then(r => r.data),
  create: (data: Omit<User, 'id'>) => api.post<User>('/users', data).then(r => r.data),
  update: (id: string, data: Partial<User>) => api.patch<User>(`/users/${id}`, data).then(r => r.data),
  remove: (id: string)   => api.delete(`/users/${id}`),
};
```

---

## Server-Sent Events (SSE)

```tsx
// Custom hook for SSE
function useSSE<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const es = new EventSource(url, { withCredentials: true });

    es.onmessage = (event) => {
      try {
        setData(JSON.parse(event.data) as T);
      } catch {
        setData(event.data as T);
      }
    };

    es.onerror = () => {
      setError('Connection lost');
      es.close();
    };

    return () => es.close();
  }, [url]);

  return { data, error };
}

// Usage
function LiveFeed() {
  const { data, error } = useSSE<FeedItem>('/api/events');
  if (error) return <Alert>{error}</Alert>;
  return <div>{data?.message}</div>;
}
```

---

## WebSocket

```tsx
// hooks/useWebSocket.ts
interface WsOptions {
  onMessage: (data: unknown) => void;
  onError?:  () => void;
  reconnectDelay?: number;
}

function useWebSocket(url: string, options: WsOptions) {
  const wsRef = useRef<WebSocket | null>(null);
  const { onMessage, onError, reconnectDelay = 3000 } = options;

  const connect = useCallback(() => {
    wsRef.current = new WebSocket(url);

    wsRef.current.onmessage = (event) => {
      try { onMessage(JSON.parse(event.data)); }
      catch { onMessage(event.data); }
    };

    wsRef.current.onerror = () => onError?.();

    wsRef.current.onclose = () => {
      setTimeout(connect, reconnectDelay);  // auto-reconnect
    };
  }, [url, onMessage, onError, reconnectDelay]);

  useEffect(() => {
    connect();
    return () => {
      wsRef.current?.close();
    };
  }, [connect]);

  const send = useCallback((data: unknown) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify(data));
    }
  }, []);

  return { send };
}
```

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| Fetching in `useEffect` without TanStack Query | Use `useQuery` — handles loading, caching, refetch |
| `queryKey: ['users']` for all user queries | Include params: `['users', userId]` — or queries collide |
| Axios without an instance | Create `api` instance — interceptors apply everywhere |
| Calling `refetch()` after mutate | Use `invalidateQueries` — let TanStack manage consistency |
| Not closing EventSource on unmount | Always return `() => es.close()` in `useEffect` |
