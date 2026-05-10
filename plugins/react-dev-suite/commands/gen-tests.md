---
description: Generate Vitest + React Testing Library tests for a component or hook. Usage: /react-dev-suite:gen-tests <file-path> [coverage: unit|integration|full]
---

Generate comprehensive tests for the specified React component or hook based on: $ARGUMENTS

## Instructions

Parse the arguments:
- **file-path** — path to the component or hook to test (required). If not provided, test the current file.
- **coverage** — depth of test coverage (default: `unit`)
  - `unit` — core behavior, main interactions, error states
  - `integration` — includes provider wrapping, API mocking with MSW, routing integration
  - `full` — unit + integration + accessibility (axe) + edge cases

## Step 1 — Read and Analyze

Read the target file and identify:
1. **Component type** — regular component, compound component, HOC, or custom hook
2. **Props interface** — all props, their types, required vs optional
3. **Interactive elements** — buttons, inputs, links, toggleable UI
4. **Async behavior** — data fetching, loading states, error states, empty states
5. **Context dependencies** — which providers are needed to render
6. **Side effects** — useEffect calls, mutations, navigation
7. **Conditional rendering** — what conditions control what's shown

## Step 2 — Generate Test File

Output file: `<same-directory>/<ComponentName>.test.tsx` or `<hookName>.test.ts`

### Test file structure

```tsx
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '../test/utils';   // custom render with providers
import userEvent from '@testing-library/user-event';
// Component import

describe('<ComponentName>', () => {
  // 1. Render tests
  // 2. Interaction tests
  // 3. Async/loading/error tests
  // 4. Accessibility test
  // 5. Edge cases
});
```

### Test categories to generate

#### Always include

**Smoke test** — component renders without crashing:
```tsx
it('renders without errors', () => {
  render(<ComponentName {...requiredProps} />);
  expect(screen.getByRole('...')).toBeInTheDocument();
});
```

**Props rendering** — key props affect output:
```tsx
it('displays the title prop', () => {
  render(<ComponentName title="Test Title" />);
  expect(screen.getByText('Test Title')).toBeInTheDocument();
});
```

**Main interactions** — primary user actions:
```tsx
it('calls onSubmit when form is submitted with valid data', async () => {
  const ue = userEvent.setup();
  const onSubmit = vi.fn();
  render(<ComponentName onSubmit={onSubmit} />);

  await ue.type(screen.getByLabelText(/name/i), 'Alice');
  await ue.click(screen.getByRole('button', { name: /submit/i }));

  await waitFor(() => expect(onSubmit).toHaveBeenCalledWith({ name: 'Alice' }));
});
```

**Null/empty/default states** — what renders when optional props are absent.

#### For components with async data

**Loading state:**
```tsx
it('shows loading skeleton while data is fetching', () => {
  server.use(http.get('/api/...', () => new Promise(() => {})));   // never resolves
  render(<ComponentName />);
  expect(screen.getByRole('progressbar')).toBeInTheDocument();
});
```

**Success state** — data renders correctly.

**Error state:**
```tsx
it('shows error message when API fails', async () => {
  server.use(http.get('/api/...', () => HttpResponse.json({ error: 'Server error' }, { status: 500 })));
  render(<ComponentName />);
  expect(await screen.findByRole('alert')).toHaveTextContent(/error/i);
});
```

**Empty state** — API returns empty array.

#### For forms

- Empty submit → validation errors shown
- Invalid field → field-level error shown
- Valid submit → onSubmit called with correct shape
- Server error → root error displayed
- Submit button disabled during submission

#### For custom hooks

```tsx
import { renderHook, act } from '@testing-library/react';

describe('useHookName', () => {
  it('returns correct initial state', () => {
    const { result } = renderHook(() => useHookName(initialArgs));
    expect(result.current.value).toBe(expectedInitialValue);
  });

  it('updates state on action', () => {
    const { result } = renderHook(() => useHookName());
    act(() => result.current.someAction());
    expect(result.current.value).toBe(newValue);
  });

  it('cleans up on unmount', () => {
    const { unmount } = renderHook(() => useHookName());
    unmount();
    // verify no warnings, subscriptions cleaned
  });
});
```

#### Accessibility test (always include for components)

```tsx
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

it('has no accessibility violations', async () => {
  const { container } = render(<ComponentName {...requiredProps} />);
  expect(await axe(container)).toHaveNoViolations();
});
```

## Step 3 — MSW Handlers (if integration coverage)

If the component uses an API, generate handler additions for the test file:
```tsx
beforeEach(() => {
  server.use(
    http.get('/api/resource', () => HttpResponse.json(mockData))
  );
});
```

## Step 4 — Coverage report

After generating, list:
- **N tests generated**
- **Paths covered**: happy path, error path, empty state, interactions
- **Paths NOT covered** (manual review needed): [list any complex edge cases]
- **Required setup**: any missing test infrastructure (MSW, providers, etc.)
