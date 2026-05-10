---
name: react-testing
description: |
  Testing React applications with JS and TS. Covers Vitest (configuration, unit
  tests, mocking, coverage), React Testing Library (render, screen queries, userEvent,
  fireEvent, async testing, waitFor), component testing patterns (forms, context,
  hooks), Mock Service Worker (MSW) for API mocking, accessibility testing
  (jest-axe, aria queries), and TypeScript ESLint for type-aware linting.

  USE WHEN: user mentions "Vitest", "React Testing Library", "RTL", "screen queries",
  "userEvent", "fireEvent", "render", "waitFor", "findBy", "queryBy", "MSW",
  "Mock Service Worker", "component test", "hook test", "accessibility test",
  "axe", "jest-axe", "typescript-eslint", "type-aware linting", "ESLint TypeScript",
  asks about "testing React", "mocking API", "test patterns", "test setup"

  DO NOT USE FOR: E2E testing (Playwright/Cypress) — use dedicated skills,
  backend testing — use framework-specific skills
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React Testing — JS & TS

---

## Setup: Vitest + React Testing Library

```bash
npm install -D vitest @vitest/coverage-v8 jsdom
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
```

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,                        // describe, it, expect without imports
    setupFiles: './src/test/setup.ts',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: ['node_modules', 'src/test'],
    },
  },
});

// src/test/setup.ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

afterEach(() => cleanup());
```

---

## Component Testing

### Query Priority (RTL best practices)

```
1. getByRole         ← preferred — tests accessibility
2. getByLabelText    ← for form fields
3. getByPlaceholderText
4. getByText
5. getByDisplayValue ← for selects, inputs with value
6. getByAltText      ← images
7. getByTitle
8. getByTestId       ← last resort — use data-testid
```

### Basic Component Test

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import UserCard from './UserCard';

describe('UserCard', () => {
  const user = { id: '1', name: 'Alice', email: 'alice@test.com' };

  it('renders user information', () => {
    render(<UserCard user={user} onSelect={vi.fn()} />);

    expect(screen.getByRole('heading', { name: /alice/i })).toBeInTheDocument();
    expect(screen.getByText('alice@test.com')).toBeInTheDocument();
  });

  it('calls onSelect when button is clicked', async () => {
    const ue = userEvent.setup();
    const onSelect = vi.fn();

    render(<UserCard user={user} onSelect={onSelect} />);
    await ue.click(screen.getByRole('button', { name: /select/i }));

    expect(onSelect).toHaveBeenCalledWith('1');
    expect(onSelect).toHaveBeenCalledTimes(1);
  });
});
```

### Async Testing

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import { server } from '../test/mocks/server';    // MSW server
import { http, HttpResponse } from 'msw';

it('shows user list after loading', async () => {
  render(<UserList />);

  // Loading state
  expect(screen.getByRole('progressbar')).toBeInTheDocument();

  // Wait for data
  await screen.findByRole('list');   // findBy = waitFor + getBy

  expect(screen.getAllByRole('listitem')).toHaveLength(3);
  expect(screen.queryByRole('progressbar')).not.toBeInTheDocument();
});

it('shows error message on API failure', async () => {
  server.use(
    http.get('/api/users', () => HttpResponse.json({ message: 'Server error' }, { status: 500 }))
  );

  render(<UserList />);

  await screen.findByRole('alert');
  expect(screen.getByRole('alert')).toHaveTextContent(/error/i);
});
```

---

## Form Testing

```tsx
import userEvent from '@testing-library/user-event';

describe('LoginForm', () => {
  it('validates required fields', async () => {
    const ue = userEvent.setup();
    render(<LoginForm onSubmit={vi.fn()} />);

    await ue.click(screen.getByRole('button', { name: /login/i }));

    expect(await screen.findByText(/email is required/i)).toBeInTheDocument();
    expect(screen.getByText(/password is required/i)).toBeInTheDocument();
  });

  it('submits with valid data', async () => {
    const ue = userEvent.setup();
    const onSubmit = vi.fn();
    render(<LoginForm onSubmit={onSubmit} />);

    await ue.type(screen.getByLabelText(/email/i), 'user@test.com');
    await ue.type(screen.getByLabelText(/password/i), 'SecurePass123');
    await ue.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'user@test.com',
        password: 'SecurePass123',
      });
    });
  });
});
```

---

## Testing with Context / Providers

```tsx
// src/test/utils.tsx — custom render with providers
import { render, type RenderOptions } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
}

interface TestWrapperProps { children: React.ReactNode; }

function AllProviders({ children }: TestWrapperProps) {
  const queryClient = createTestQueryClient();
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={testTheme}>
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  );
}

function customRender(ui: React.ReactElement, options?: RenderOptions) {
  return render(ui, { wrapper: AllProviders, ...options });
}

export * from '@testing-library/react';
export { customRender as render };

// In tests — just import from utils instead of RTL
import { render, screen } from '../test/utils';
```

---

## Testing Custom Hooks

```tsx
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('increments count', () => {
    const { result } = renderHook(() => useCounter({ initial: 0 }));

    act(() => result.current.increment());

    expect(result.current.count).toBe(1);
  });

  it('respects max limit', () => {
    const { result } = renderHook(() => useCounter({ initial: 4, max: 5 }));

    act(() => { result.current.increment(); result.current.increment(); });

    expect(result.current.count).toBe(5);
  });
});
```

---

## MSW — API Mocking

```bash
npm install -D msw
npx msw init public/ --save
```

```ts
// src/test/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () =>
    HttpResponse.json([
      { id: '1', name: 'Alice', email: 'alice@test.com' },
      { id: '2', name: 'Bob',   email: 'bob@test.com' },
    ])
  ),
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: '3', ...body }, { status: 201 });
  }),
  http.get('/api/users/:id', ({ params }) => {
    if (params.id === '404') return new HttpResponse(null, { status: 404 });
    return HttpResponse.json({ id: params.id, name: 'Alice' });
  }),
];

// src/test/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';
export const server = setupServer(...handlers);

// src/test/setup.ts — add to existing setup
import { server } from './mocks/server';
beforeAll(()  => server.listen({ onUnhandledRequest: 'error' }));
afterEach(()  => server.resetHandlers());
afterAll(()   => server.close());
```

---

## Accessibility Testing

```bash
npm install -D jest-axe axe-core
```

```tsx
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

it('has no accessibility violations', async () => {
  const { container } = render(<LoginForm onSubmit={vi.fn()} />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

---

## TypeScript ESLint Setup

```bash
npm install -D typescript-eslint eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

```ts
// eslint.config.ts (flat config)
import tseslint from 'typescript-eslint';

export default tseslint.config(
  ...tseslint.configs.strictTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        project: './tsconfig.json',
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      '@typescript-eslint/no-explicit-any':        'error',
      '@typescript-eslint/no-floating-promises':   'error',
      '@typescript-eslint/no-unused-vars':         ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/prefer-nullish-coalescing': 'warn',
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
    },
  }
);
```

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| `getByTestId` as first query | Prefer `getByRole` — it tests accessibility too |
| `waitFor` with `getBy*` inside | Use `findBy*` — it's `waitFor` + `getBy` combined |
| `act()` everywhere manually | `userEvent` wraps in `act` automatically |
| Testing implementation details | Test behavior — what the user sees and does |
| One huge test file | Group by feature; one `describe` per component/hook |
| Not resetting MSW handlers | Use `afterEach(() => server.resetHandlers())` |
