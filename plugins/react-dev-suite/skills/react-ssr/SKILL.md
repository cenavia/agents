---
name: react-ssr
description: |
  Server-Side Rendering and server-driven patterns in React with TS. Covers React
  Server Components (RSC) — Server vs Client component boundaries, async server
  components, data fetching without useEffect, streaming SSR, Suspense with RSC —
  and View Transitions API (useViewTransition, addTransitionType, CSS animations,
  Next.js App Router patterns). Focused on Next.js App Router as the primary RSC host.

  USE WHEN: user mentions "React Server Components", "RSC", "Server Components",
  "Client Components", "use client", "use server", "Server Actions", "Next.js App Router",
  "App Router", "async component", "streaming SSR", "View Transitions", "useViewTransition",
  "addTransitionType", "page transition", "shared element transition",
  asks about "SSR", "server-side rendering", "server data fetching", "hydration"

  DO NOT USE FOR: client-side data fetching — use react-dev-suite:react-data,
  routing — use react-dev-suite:react-routing,
  basic React patterns — use react-dev-suite:react-core
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React SSR — Server Components & View Transitions

---

## React Server Components (RSC)

### Server vs Client — Decision Rules

| Component type | When to use |
|---|---|
| **Server Component** (default) | Data fetching, DB/file access, no interactivity, reduce JS bundle |
| **Client Component** (`'use client'`) | useState, useEffect, event handlers, browser APIs, third-party client libs |

```
app/
├── page.tsx              ← Server Component (default)
├── layout.tsx            ← Server Component (default)
├── components/
│   ├── UserProfile.tsx   ← Server Component — no interactivity
│   ├── LikeButton.tsx    ← Client Component — uses useState
│   └── Chart.tsx         ← Client Component — uses browser API
```

### Async Server Component — Direct Data Fetching

```tsx
// app/users/page.tsx — Server Component
// No useEffect, no loading state, no client JS for data fetching

async function UsersPage() {
  // Runs on server — can use DB, env secrets, filesystem
  const users = await db.query('SELECT * FROM users ORDER BY name');

  return (
    <main>
      <h1>Users</h1>
      <Suspense fallback={<UserListSkeleton />}>
        <UserList users={users} />
      </Suspense>
    </main>
  );
}

// Async component with error handling
async function UserProfile({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  const user = await usersService.getById(id);
  if (!user) notFound();      // throws Next.js 404

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      {/* Server component can render Client components as children */}
      <FollowButton userId={user.id} />
    </div>
  );
}
```

### Client Component — The 'use client' Boundary

```tsx
'use client';   // marks this and ALL its imports as client-side

import { useState } from 'react';

// Client components can receive Server Component output as props/children
interface FollowButtonProps {
  userId: string;
  initialFollowing: boolean;
}

export function FollowButton({ userId, initialFollowing }: FollowButtonProps) {
  const [following, setFollowing] = useState(initialFollowing);
  const [pending, setPending] = useState(false);

  async function toggle() {
    setPending(true);
    await followUser(userId, !following);
    setFollowing(f => !f);
    setPending(false);
  }

  return (
    <button onClick={toggle} disabled={pending} aria-pressed={following}>
      {following ? 'Following' : 'Follow'}
    </button>
  );
}
```

### Server Actions

```tsx
// app/actions/posts.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  const body  = formData.get('body') as string;

  // Validation
  if (!title || title.length < 3) {
    return { error: 'Title must be at least 3 characters' };
  }

  const post = await postsDb.create({ title, body });
  revalidatePath('/posts');          // revalidate cached pages
  redirect(`/posts/${post.id}`);
}

// Using Server Action with useActionState (React 19)
'use client';
import { useActionState } from 'react';
import { createPost } from '../actions/posts';

export function CreatePostForm() {
  const [state, action, isPending] = useActionState(createPost, null);

  return (
    <form action={action}>
      <input name="title" required />
      <textarea name="body" required />
      {state?.error && <p role="alert">{state.error}</p>}
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating…' : 'Create Post'}
      </button>
    </form>
  );
}
```

### Streaming with Suspense

```tsx
// app/dashboard/page.tsx — stream sections independently
import { Suspense } from 'react';

export default function DashboardPage() {
  return (
    <div className="grid grid-cols-3 gap-6">

      {/* Fast — renders immediately */}
      <header><h1>Dashboard</h1></header>

      {/* Slow query — streams when ready */}
      <Suspense fallback={<StatsSkeleton />}>
        <StatsSection />          {/* async server component */}
      </Suspense>

      <Suspense fallback={<FeedSkeleton />}>
        <ActivityFeed />          {/* async server component */}
      </Suspense>

      <Suspense fallback={<ChartSkeleton />}>
        <RevenueChart />          {/* async server component */}
      </Suspense>

    </div>
  );
}

async function StatsSection() {
  const stats = await fetchDashboardStats();   // slow query, but doesn't block others
  return <StatsGrid stats={stats} />;
}
```

### Caching Strategies (Next.js)

```tsx
// Force cache (default for fetch)
const data = await fetch('/api/products', { cache: 'force-cache' });

// No cache (always fresh)
const data = await fetch('/api/cart', { cache: 'no-store' });

// Time-based revalidation
const data = await fetch('/api/posts', { next: { revalidate: 3600 } }); // 1 hour

// On-demand revalidation in Server Action
import { revalidateTag, revalidatePath } from 'next/cache';
revalidateTag('products');
revalidatePath('/products');
```

---

## View Transitions API

```tsx
'use client';
import { useTransition } from 'react';

// Basic View Transition — wraps navigation in browser animation
function NavigationLink({ href, children }: { href: string; children: React.ReactNode }) {
  const [isPending, startTransition] = useTransition();
  const router = useRouter();

  function handleClick() {
    startTransition(() => {
      // React 19 — startTransition + navigation = View Transition
      router.push(href);
    });
  }

  return (
    <a href={href} onClick={(e) => { e.preventDefault(); handleClick(); }}
       style={{ opacity: isPending ? 0.7 : 1 }}>
      {children}
    </a>
  );
}
```

### CSS Animations for View Transitions

```css
/* globals.css */

/* Default cross-fade */
@keyframes fade-in  { from { opacity: 0; } to { opacity: 1; } }
@keyframes fade-out { from { opacity: 1; } to { opacity: 0; } }

::view-transition-new(root) { animation: fade-in  300ms ease-in; }
::view-transition-old(root) { animation: fade-out 300ms ease-out; }

/* Named transition — slide for page navigation */
::view-transition-new(page)  { animation: slide-in  300ms ease-out; }
::view-transition-old(page)  { animation: slide-out 300ms ease-in; }

@keyframes slide-in  { from { transform: translateX(100%); } to { transform: translateX(0); } }
@keyframes slide-out { from { transform: translateX(0); } to { transform: translateX(-100%); } }
```

```tsx
// Shared element transition — element animates between views
function ProductCard({ product }: { product: Product }) {
  return (
    <div
      style={{ viewTransitionName: `product-${product.id}` }}  // must be unique
    >
      <img
        src={product.image}
        style={{ viewTransitionName: `product-image-${product.id}` }}
      />
      <h3>{product.name}</h3>
    </div>
  );
}
```

---

## RSC Patterns — Quick Reference

| Pattern | Server | Client |
|---|---|---|
| Database query | ✅ | ❌ |
| Env secrets | ✅ | ❌ (NEXT_PUBLIC_ only) |
| `useState` / `useEffect` | ❌ | ✅ |
| Event handlers | ❌ | ✅ |
| Async/await in component | ✅ | ❌ (use TanStack Query) |
| Access `cookies()` / `headers()` | ✅ | ❌ |
| Third-party UI components | ❌ (usually) | ✅ |

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| `'use client'` on every component | Only add where interactivity is needed; keep data-fetching in Server |
| Import heavy client lib in Server Component | Move to Client Component or dynamic import |
| `useEffect` for data in App Router | Use async Server Component instead |
| Sequential `await` in Server Component | `Promise.all` for parallel fetching |
| Server Action without validation | Always validate + sanitize server-side — client code is untrusted |
| Large Client Component boundary | Push `'use client'` as deep as possible to maximize server rendering |
