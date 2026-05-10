---
description: Performance audit of a React component or page — identifies re-render issues, memoization opportunities, waterfall requests, and bundle size concerns. Usage: /react-dev-suite:perf-audit [file-path or feature-name]
---

Perform a React performance audit based on: $ARGUMENTS

## Instructions

If a file path is given, read it. If a feature/page name is given, find and read the relevant files. If no argument, audit the current file.

For large pages, also read child components that are rendered directly.

---

## Audit Areas

### 1. Re-render Analysis

Scan for patterns that cause unnecessary re-renders:

**Inline objects/arrays as props:**
```tsx
// ❌ New object reference on every render
<Card style={{ padding: 16, margin: 8 }} filters={['active', 'pending']} />

// ✅ Stable references
const CARD_STYLE = { padding: 16, margin: 8 };
const STATUS_FILTERS = ['active', 'pending'] as const;
<Card style={CARD_STYLE} filters={STATUS_FILTERS} />
```

**Inline callbacks passed to memoized children:**
```tsx
// ❌ New function reference defeats React.memo
<MemoizedList onSelect={(id) => setSelected(id)} />

// ✅ Stable callback
const handleSelect = useCallback((id: string) => setSelected(id), []);
<MemoizedList onSelect={handleSelect} />
```

**Context value not memoized:**
```tsx
// ❌ New object on every Provider render → all consumers re-render
<Context.Provider value={{ user, logout }}>

// ✅ Memoized value
const value = useMemo(() => ({ user, logout }), [user, logout]);
<Context.Provider value={value}>
```

**Derived state stored in useState:**
```tsx
// ❌ Extra state + sync effect = double render
const [filtered, setFiltered] = useState([]);
useEffect(() => setFiltered(items.filter(i => i.active)), [items]);

// ✅ Compute during render (or useMemo if expensive)
const filtered = useMemo(() => items.filter(i => i.active), [items]);
```

### 2. Request Waterfall Detection

Look for sequential await patterns in components or hooks:
```tsx
// ❌ Sequential — 3× the latency
const user  = await fetchUser(id);
const posts = await fetchPosts(user.id);
const stats = await fetchStats(user.id);

// ✅ Parallel — latency of the slowest request
const [user, posts, stats] = await Promise.all([
  fetchUser(id),
  fetchPosts(id),
  fetchStats(id),
]);
```

Also check for **component-level waterfalls** — parent fetches data, then child component mounts and fetches its own data. Solution: lift fetch to parent or use route loaders.

### 3. Code Splitting Opportunities

Check for:
- Large page components (> 300 lines) not wrapped in `lazy()`
- Heavy UI libraries imported at the top of frequently-loaded modules
- Images not using `loading="lazy"`

```tsx
// ❌ Heavy component in main bundle
import { RichEditor } from './RichEditor';

// ✅ Split — only loaded when needed
const RichEditor = lazy(() => import('./RichEditor'));
```

### 4. Memoization Assessment

**Over-memoization (costs without benefit):**
```tsx
// ❌ useMemo on trivial computation — overhead > benefit
const doubled = useMemo(() => count * 2, [count]);
// ✅
const doubled = count * 2;
```

**Missing memoization (actually expensive):**
```tsx
// ❌ Expensive filter runs on every render
const results = items
  .filter(i => i.tags.some(t => selectedTags.includes(t)))
  .sort((a, b) => a.score - b.score);

// ✅ Only recomputes when deps change
const results = useMemo(() =>
  items
    .filter(i => i.tags.some(t => selectedTags.includes(t)))
    .sort((a, b) => a.score - b.score),
  [items, selectedTags]
);
```

**React.memo missing on frequently-rendered children:**
Check if a child component is rendered inside a list or receives stable props from a parent that re-renders often.

### 5. List Virtualization Check

If any array is rendered with `.map()` and could contain > 100 items, flag it:
```tsx
// ❌ Renders all items in DOM — slow with large datasets
{notifications.map(n => <NotificationRow key={n.id} {...n} />)}

// ✅ Only renders visible rows
import { useVirtualizer } from '@tanstack/react-virtual';
```

### 6. Bundle Impact

Check for:
- Full library imports instead of tree-shakeable named imports:
```tsx
// ❌ Imports entire lodash bundle (~70 KB)
import _ from 'lodash';
_.debounce(fn, 300);

// ✅ Tree-shakeable
import { debounce } from 'lodash-es';
// Or native: use useDeferredValue / setTimeout
```

---

## Output Format

### Performance Audit — [File/Feature] — [Date]

#### Summary
[Estimated render performance: Good / Needs Attention / Poor]  
[Data fetching pattern: Optimized / Waterfall detected]  
[Bundle contribution: Low / Medium / High]

#### 🔴 Critical Performance Issues
Performance problems that visibly affect UX — with fix

#### 🟡 Optimization Opportunities
Improvements that would measurably help — with before/after code

#### 🔵 Minor Suggestions
Low-impact cleanups

#### Profiling Recommendation
Specific instructions for using React DevTools Profiler to measure the most impactful issue:
1. Open React DevTools → Profiler tab
2. Click Record, perform [specific action]
3. Look for [component] taking > Xms per render
4. Expected improvement after fix: [description]
