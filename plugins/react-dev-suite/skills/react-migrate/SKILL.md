---
name: react-migrate
description: |
  React version migration patterns and audit tools for JS and TS codebases.
  Covers migrating to React 18 (automatic batching, new root API, Strict Mode
  double-invoke), migrating to React 19 (deprecated APIs removal, ref handling,
  context changes, act() import changes), Enzyme to React Testing Library migration,
  string refs to createRef migration, legacy Context API migration, React 18.3.1
  and React 19 dependency compatibility matrix, and grep audit commands for
  pre-upgrade scanning.

  USE WHEN: user mentions "React migration", "upgrade React", "React 18", "React 19",
  "deprecated API", "componentWillMount", "componentWillUpdate", "componentWillReceiveProps",
  "string refs", "legacy context", "contextTypes", "childContextTypes",
  "Enzyme to RTL", "enzyme migration", "automatic batching", "createRoot",
  "react 18 upgrade", "react 19 upgrade", "UNSAFE_ lifecycle", "react-dom/client",
  asks about "breaking changes", "migration guide", "compatibility matrix"

  DO NOT USE FOR: new React 19 features — use react-dev-suite:react-core,
  testing setup — use react-dev-suite:react-testing
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# React Migration Guide — 18 & 19

---

## Pre-Migration Audit (grep commands)

Run these scans before upgrading to identify work needed:

```bash
# Find deprecated lifecycle methods
grep -rn "componentWillMount\|componentWillUpdate\|componentWillReceiveProps" src/ --include="*.{js,jsx,ts,tsx}"

# Find UNSAFE_ lifecycles
grep -rn "UNSAFE_componentWillMount\|UNSAFE_componentWillUpdate\|UNSAFE_componentWillReceiveProps" src/ --include="*.{js,jsx,ts,tsx}"

# Find string refs (React 19 removes these)
grep -rn 'ref="[^"]*"' src/ --include="*.{js,jsx,ts,tsx}"
grep -rn 'this\.refs\.' src/ --include="*.{js,jsx,ts,tsx}"

# Find legacy context API
grep -rn "contextTypes\|childContextTypes\|getChildContext" src/ --include="*.{js,jsx,ts,tsx}"

# Find ReactDOM.render (replaced by createRoot in React 18)
grep -rn "ReactDOM\.render\|ReactDOM\.hydrate" src/ --include="*.{js,jsx,ts,tsx}"

# Find React.createFactory (removed in React 19)
grep -rn "React\.createFactory\|createFactory" src/ --include="*.{js,jsx,ts,tsx}"

# Find defaultProps on function components (deprecated React 19)
grep -rn "\.defaultProps\s*=" src/ --include="*.{js,jsx,ts,tsx}"

# Find Enzyme imports
grep -rn "from 'enzyme'\|require('enzyme')\|from '@wojtekmaj/enzyme-adapter'" src/ --include="*.{js,jsx,ts,tsx}"

# Find act() import source (must change in React 19)
grep -rn "from 'react-dom/test-utils'" src/ --include="*.{js,jsx,ts,tsx}"
```

---

## React 17 → 18 Migration

### 1. New Root API

```tsx
// Before (React 17)
import ReactDOM from 'react-dom';
ReactDOM.render(<App />, document.getElementById('root'));

// After (React 18)
import { createRoot } from 'react-dom/client';
const root = createRoot(document.getElementById('root')!);
root.render(<App />);

// SSR hydration
// Before: ReactDOM.hydrate(...)
// After:
import { hydrateRoot } from 'react-dom/client';
hydrateRoot(document, <App />);
```

### 2. Automatic Batching

```tsx
// React 18 batches setState calls in async functions, setTimeout, Promises
// Previously only batched in React event handlers

// This now causes ONE re-render (was TWO in React 17)
setTimeout(() => {
  setCount(c => c + 1);
  setFlag(f => !f);
}, 1000);

// If you NEED separate renders (rare):
import { flushSync } from 'react-dom';
flushSync(() => setCount(c => c + 1));
flushSync(() => setFlag(f => !f));
```

### 3. Strict Mode Changes

React 18 Strict Mode **double-invokes** effects in development:
- `useEffect` setup+cleanup runs twice on mount
- `useReducer` / `useState` initializers run twice

```tsx
// Ensure effects are truly idempotent and cleanup is complete
useEffect(() => {
  const subscription = subscribe();
  return () => subscription.unsubscribe();  // must fully clean up
}, []);
```

---

## React 18 → 19 Migration

### 1. Removed APIs

```tsx
// ❌ React.createFactory — removed
const button = React.createFactory('button');
// ✅ Use JSX directly
const button = <button />;

// ❌ ReactDOM.render / ReactDOM.hydrate — removed (were deprecated in 18)
ReactDOM.render(<App />, container);
// ✅ createRoot
createRoot(container).render(<App />);

// ❌ defaultProps on function components — deprecated
MyComponent.defaultProps = { color: 'red' };
// ✅ Default parameters
function MyComponent({ color = 'red' }: Props) {}

// ❌ propTypes — removed (use TypeScript)
MyComponent.propTypes = { name: PropTypes.string };
// ✅ TypeScript interface
interface Props { name: string; }
```

### 2. Ref Handling

```tsx
// ❌ forwardRef wrapper — no longer needed in React 19
const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => (
  <input ref={ref} {...props} />
));

// ✅ React 19 — ref is a regular prop
function Input({ ref, ...props }: React.ComponentProps<'input'>) {
  return <input ref={ref} {...props} />;
}

// String refs — REMOVED in React 19
// ❌
<input ref="myInput" />
this.refs.myInput.focus();

// ✅
const inputRef = useRef<HTMLInputElement>(null);
<input ref={inputRef} />
inputRef.current?.focus();
```

### 3. Context API Change

```tsx
// ❌ Context.Consumer — still works but Legacy
<ThemeContext.Consumer>
  {(theme) => <div className={theme} />}
</ThemeContext.Consumer>

// ✅ Preferred — useContext hook
function ThemedDiv() {
  const theme = useContext(ThemeContext);
  return <div className={theme} />;
}

// React 19: <Context> replaces <Context.Provider>
// ❌ Old
<ThemeContext.Provider value="dark"><App /></ThemeContext.Provider>
// ✅ New (React 19)
<ThemeContext value="dark"><App /></ThemeContext>
```

### 4. Test File Changes

```tsx
// ❌ Old — act from react-dom/test-utils
import { act } from 'react-dom/test-utils';

// ✅ React 19 — act from react
import { act } from 'react';

// ❌ Simulate removed from Enzyme-style patterns
import { Simulate } from 'react-dom/test-utils';
Simulate.click(element);

// ✅ userEvent (RTL)
import userEvent from '@testing-library/user-event';
await userEvent.click(element);
```

---

## Enzyme → React Testing Library Migration

### Query Equivalents

| Enzyme | RTL Equivalent |
|---|---|
| `wrapper.find('button')` | `screen.getByRole('button')` |
| `wrapper.find('[data-testid="x"]')` | `screen.getByTestId('x')` |
| `wrapper.text()` | `element.textContent` |
| `wrapper.prop('onClick')` | Test by firing event |
| `wrapper.state()` | Test behavior, not state |
| `wrapper.instance()` | N/A — test behavior |

```tsx
// ❌ Enzyme
import { shallow, mount } from 'enzyme';

describe('Counter', () => {
  it('increments count', () => {
    const wrapper = shallow(<Counter />);
    expect(wrapper.find('p').text()).toBe('Count: 0');
    wrapper.find('button').simulate('click');
    expect(wrapper.find('p').text()).toBe('Count: 1');
  });
});

// ✅ React Testing Library
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('Counter', () => {
  it('increments count', async () => {
    const ue = userEvent.setup();
    render(<Counter />);

    expect(screen.getByText('Count: 0')).toBeInTheDocument();
    await ue.click(screen.getByRole('button', { name: /increment/i }));
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
  });
});
```

---

## Legacy Context → Modern Context

```tsx
// ❌ Legacy context (React 18.3 warning, React 19 removed)
class ThemeProvider extends Component {
  static childContextTypes = { theme: PropTypes.string };
  getChildContext() { return { theme: 'dark' }; }
}

class Button extends Component {
  static contextTypes = { theme: PropTypes.string };
  render() { return <button className={this.context.theme}>Click</button>; }
}

// ✅ Modern context
const ThemeContext = createContext<string>('light');

function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState('dark');
  return <ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>;
}

function Button() {
  const theme = useContext(ThemeContext);
  return <button className={theme}>Click</button>;
}
```

---

## Dependency Compatibility Matrix

| Package | React 18 | React 19 |
|---|---|---|
| react-router-dom | v6.x ✅ | v6.28+ ✅ |
| @tanstack/react-query | v5.x ✅ | v5.x ✅ |
| @tanstack/react-router | v1.x ✅ | v1.x ✅ |
| zustand | v4.x ✅ | v5.x ✅ |
| @reduxjs/toolkit | v2.x ✅ | v2.3+ ✅ |
| @mui/material | v5.x ✅ | v6.x ✅ |
| react-hook-form | v7.x ✅ | v7.x ✅ |
| framer-motion | v10.x ✅ | v11.x ✅ |
| enzyme | ❌ no React 18 support | ❌ migrate to RTL |

---

## Migration Checklist

### React 17 → 18
- [ ] Replace `ReactDOM.render` with `createRoot`
- [ ] Replace `ReactDOM.hydrate` with `hydrateRoot`
- [ ] Audit `useEffect` for double-invoke issues (Strict Mode)
- [ ] Check batching behavior changes (async setState)
- [ ] Update `@testing-library/react` to v13+

### React 18 → 19
- [ ] Remove `React.createFactory` usage
- [ ] Replace `forwardRef` wrappers (ref as regular prop)
- [ ] Remove `.defaultProps` from function components
- [ ] Remove `propTypes` (replace with TypeScript)
- [ ] Update `Context.Provider` → `Context` as JSX element
- [ ] Update `act` import to `from 'react'`
- [ ] Audit string refs (none allowed)
- [ ] Audit legacy context API
- [ ] Update package dependencies (see matrix above)
