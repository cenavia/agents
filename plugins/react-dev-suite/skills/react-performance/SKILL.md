---
name: react-performance
description: |
  Performance optimization for React applications with JS and TS. Covers memoization
  (React.memo, useMemo, useCallback), virtualization (react-window, react-virtual),
  code splitting (lazy, Suspense, dynamic imports), bundle analysis, Vercel best
  practices (eliminating request waterfalls, avoiding client-side data fetching,
  re-render optimization, server performance), composition patterns (avoiding
  boolean prop proliferation), and React Concurrent features for responsiveness.

  USE WHEN: user mentions "slow React", "performance", "memoization", "React.memo",
  "useMemo", "useCallback", "virtualization", "virtual list", "code splitting",
  "lazy loading", "bundle size", "re-renders", "profiler", "waterfall",
  "useTransition", "useDeferredValue", "Suspense", asks about "optimizing",
  "preventing re-renders", "bundle optimization", "Vercel performance"

  DO NOT USE FOR: basic React patterns — use react-dev-suite:react-core,
  data caching — use react-dev-suite:react-data
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React Performance Optimization — JS & TS

---

## Memoization

### React.memo — Prevent Child Re-renders

```tsx
// Only re-renders when props change (shallow equality)
const ProductCard = memo(function ProductCard({ product, onAddToCart }: ProductCardProps) {
  return (
    <div>
      <h3>{product.name}</h3>
      <button onClick={() => onAddToCart(product.id)}>Add to Cart</button>
    </div>
  );
});

// Parent: memoize the callback to stabilize the reference
function ProductList({ products }: { products: Product[] }) {
  const handleAddToCart = useCallback((id: string) => {
    cartStore.addItem(id);
  }, []);  // stable — no deps

  return products.map(p => (
    <ProductCard key={p.id} product={p} onAddToCart={handleAddToCart} />
  ));
}
```

### useMemo — Expensive Computations

```tsx
// Only recompute when dependencies change
const filteredAndSorted = useMemo(() => {
  return products
    .filter(p => p.category === selectedCategory && p.price <= maxPrice)
    .sort((a, b) => a.name.localeCompare(b.name));
}, [products, selectedCategory, maxPrice]);

// When NOT to memoize — cost > benefit
// ❌ const doubled = useMemo(() => count * 2, [count]);  // trivial computation
// ✅ const doubled = count * 2;
```

---

## Eliminating Request Waterfalls (Vercel Rule)

```tsx
// ❌ Sequential waterfall — each await blocks the next
async function Dashboard() {
  const user    = await fetchUser();     // 200ms
  const posts   = await fetchPosts();   // 200ms — waits for user
  const stats   = await fetchStats();   // 200ms — waits for posts
  // Total: ~600ms
}

// ✅ Parallel fetching
async function Dashboard() {
  const [user, posts, stats] = await Promise.all([
    fetchUser(),
    fetchPosts(),
    fetchStats(),
  ]);
  // Total: ~200ms
}

// ✅ TanStack Query — automatic parallel
function Dashboard() {
  const { data: user }  = useQuery(userQueries.current());
  const { data: posts } = useQuery(postQueries.all());
  const { data: stats } = useQuery(statsQueries.dashboard());
  // All requests fire simultaneously
}
```

---

## Code Splitting

```tsx
// Route-level splitting — most impactful
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings  = lazy(() => import('./pages/Settings'));
const Analytics = lazy(() => import('./pages/Analytics'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings"  element={<Settings />} />
        <Route path="/analytics" element={<Analytics />} />
      </Routes>
    </Suspense>
  );
}

// Component-level splitting — heavy UI components
const RichEditor = lazy(() => import('./components/RichEditor'));

function DocumentEditor({ showEditor }: { showEditor: boolean }) {
  return (
    <div>
      {showEditor && (
        <Suspense fallback={<EditorSkeleton />}>
          <RichEditor />
        </Suspense>
      )}
    </div>
  );
}
```

---

## List Virtualization

```bash
npm install @tanstack/react-virtual
```

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 72,     // estimated row height in px
    overscan: 5,                 // extra rows rendered off-screen
  });

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <div
            key={virtualRow.key}
            style={{
              position: 'absolute',
              top: 0,
              transform: `translateY(${virtualRow.start}px)`,
              width: '100%',
            }}
          >
            <ItemRow item={items[virtualRow.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## Concurrent Features for Responsiveness

```tsx
// useTransition — keep UI responsive during heavy state updates
function SearchPage() {
  const [query, setQuery]   = useState('');
  const [results, setResults] = useState<Result[]>([]);
  const [isPending, startTransition] = useTransition();

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    const value = e.target.value;
    setQuery(value);                           // urgent — update input immediately
    startTransition(() => {
      setResults(expensiveSearch(value));      // non-urgent — can be interrupted
    });
  }

  return (
    <>
      <input value={query} onChange={handleChange} />
      {isPending && <Spinner />}
      <SearchResults results={results} />
    </>
  );
}

// useDeferredValue — defer re-render of expensive child
function App() {
  const [query, setQuery] = useState('');
  const deferredQuery = useDeferredValue(query);

  return (
    <>
      <input onChange={e => setQuery(e.target.value)} />
      {/* SearchResults only re-renders when React has idle time */}
      <SearchResults query={deferredQuery} />
    </>
  );
}
```

---

## Composition Patterns (Avoiding Prop Proliferation)

```tsx
// ❌ Boolean prop explosion — adding features = adding props
<Modal
  hasCloseButton
  hasFooter
  hasConfirmButton
  isLoading
  isFullscreen
/>

// ✅ Slot-based composition — consumers control structure
<Modal>
  <Modal.Header>
    <Modal.Title>Confirm Delete</Modal.Title>
    <Modal.CloseButton />
  </Modal.Header>
  <Modal.Body>Are you sure?</Modal.Body>
  <Modal.Footer>
    <Button variant="ghost">Cancel</Button>
    <Button variant="danger" loading={isDeleting}>Delete</Button>
  </Modal.Footer>
</Modal>
```

---

## Bundle Size Optimization

```ts
// vite.config.ts — manual chunks for optimal splitting
import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor':   ['react', 'react-dom'],
          'router-vendor':  ['react-router-dom'],
          'query-vendor':   ['@tanstack/react-query'],
          'ui-vendor':      ['@mui/material'],
        },
      },
    },
    chunkSizeWarningLimit: 500,   // warn if chunk > 500 KB
  },
});
```

```bash
# Analyze bundle
npm install -D rollup-plugin-visualizer

# Add to vite.config.ts plugins:
# visualizer({ open: true, gzipSize: true })
```

---

## Performance Checklist

| Area | Action |
|---|---|
| Re-renders | Use React DevTools Profiler to identify |
| Memoization | Only where benchmark shows measurable gain |
| Code splitting | At route level minimum; heavy components next |
| Virtualization | Lists > 100 items |
| Images | `loading="lazy"`, `width`/`height` attrs, WebP |
| Waterfalls | `Promise.all` or TanStack Query parallel queries |
| Bundle | Analyze with visualizer; dynamic imports for large deps |

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| `useMemo` / `memo` everywhere | Only memoize based on profiler evidence |
| Inline function in JSX without `useCallback` | Use `useCallback` only when passed to memo'd child |
| `key={index}` on reordered lists | Use stable unique IDs |
| Heavy computation in render | Move to `useMemo` or worker |
| `useEffect` for derived state | Compute inline; skip the extra render cycle |
