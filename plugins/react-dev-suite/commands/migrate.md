---
description: Plan and execute a React version migration (17→18, 18→19) or specific API migration. Usage: /react-dev-suite:migrate [target: 18|19|enzyme-to-rtl|string-refs|legacy-context|forwardRef]
---

Plan and execute a React migration based on: $ARGUMENTS

## Instructions

Parse the migration target (default: auto-detect from installed React version):
- `18` — migrate to React 18 (ReactDOM.render → createRoot, batch updates)
- `19` — migrate to React 19 (remove deprecated APIs, forwardRef, defaultProps, etc.)
- `enzyme-to-rtl` — migrate all Enzyme tests to React Testing Library
- `string-refs` — migrate all string refs to createRef/useRef
- `legacy-context` — migrate contextTypes/childContextTypes to modern Context API
- `forwardRef` — convert forwardRef wrappers to React 19 ref-as-prop pattern

## Phase 1 — Audit First

Before touching any file, run the audit command mentally with Bash:

```bash
# Detect current React version
cat package.json | grep '"react":'

# Count migration targets
grep -rn "<target-pattern>" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null | wc -l
```

Report the count of items to migrate. If 0, confirm "Nothing to migrate for this target."

## Phase 2 — Migration Plan

Present a plan:
1. Total files to modify
2. Estimated risk (files with complex logic)
3. Order of changes (safest/most isolated first)
4. Packages to update with exact versions

## Phase 3 — Execute Migration

### Target: `18` (React 18)

**Packages:**
```bash
npm install react@18 react-dom@18
npm install -D @types/react@18 @types/react-dom@18
```

**Pattern: ReactDOM.render → createRoot**
```tsx
// Before
import ReactDOM from 'react-dom';
ReactDOM.render(<App />, document.getElementById('root'));

// After
import { createRoot } from 'react-dom/client';
createRoot(document.getElementById('root')!).render(<App />);
```

**Pattern: ReactDOM.hydrate → hydrateRoot**
```tsx
// Before
ReactDOM.hydrate(<App />, document.getElementById('root'));
// After
import { hydrateRoot } from 'react-dom/client';
hydrateRoot(document.getElementById('root')!, <App />);
```

**Automatic batching check:**
Review all `useEffect` bodies that call multiple `setState` — they now batch. Check for cases where you relied on separate renders. If needed, wrap individual sets in `flushSync`.

---

### Target: `19` (React 19)

**Packages:**
```bash
npm install react@19 react-dom@19
npm install -D @types/react@19 @types/react-dom@19
```

**Pattern: Remove createFactory**
```tsx
// Before
const el = React.createFactory('div')({ className: 'box' }, 'content');
// After
const el = <div className="box">content</div>;
```

**Pattern: Remove defaultProps on function components**
```tsx
// Before
function Btn({ color }: BtnProps) { return <button style={{ color }}/>; }
Btn.defaultProps = { color: 'blue' };
// After
function Btn({ color = 'blue' }: BtnProps) { return <button style={{ color }}/>; }
```

**Pattern: forwardRef → ref as prop**
```tsx
// Before
const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => (
  <input ref={ref} {...props} />
));
Input.displayName = 'Input';
// After
function Input({ ref, ...props }: React.ComponentProps<'input'>) {
  return <input ref={ref} {...props} />;
}
```

**Pattern: Context.Provider → Context as JSX**
```tsx
// Before
<ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>
// After
<ThemeContext value={theme}>{children}</ThemeContext>
```

**Pattern: act import**
```tsx
// Before
import { act } from 'react-dom/test-utils';
// After
import { act } from 'react';
```

---

### Target: `enzyme-to-rtl`

**Packages to remove/add:**
```bash
npm uninstall enzyme enzyme-adapter-react-16 @wojtekmaj/enzyme-adapter-react-18
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
```

**Pattern equivalents:**
```tsx
// Before (Enzyme)
const wrapper = shallow(<Button onClick={mockFn} label="Save" />);
expect(wrapper.find('button').text()).toBe('Save');
wrapper.find('button').simulate('click');
expect(mockFn).toHaveBeenCalled();

// After (RTL)
render(<Button onClick={mockFn} label="Save" />);
expect(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
await userEvent.click(screen.getByRole('button', { name: 'Save' }));
expect(mockFn).toHaveBeenCalled();
```

```tsx
// Before (Enzyme — accessing props/state)
expect(wrapper.prop('disabled')).toBe(true);
expect(wrapper.state('count')).toBe(0);

// After (RTL — test behavior, not implementation)
expect(screen.getByRole('button')).toBeDisabled();
// Test what the user sees, not internal state
```

---

### Target: `string-refs`

```tsx
// Before (class component)
class Form extends Component {
  handleSubmit() { this.refs.email.focus(); }
  render() { return <input ref="email" name="email" />; }
}

// After (class — createRef)
class Form extends Component {
  emailRef = createRef<HTMLInputElement>();
  handleSubmit() { this.emailRef.current?.focus(); }
  render() { return <input ref={this.emailRef} name="email" />; }
}

// After (functional — useRef)
function Form() {
  const emailRef = useRef<HTMLInputElement>(null);
  return <input ref={emailRef} name="email" />;
}
```

---

### Target: `legacy-context`

```tsx
// Before
class Button extends Component {
  static contextTypes = { theme: PropTypes.string };
  render() { return <button className={this.context.theme}>{this.props.children}</button>; }
}

// After
const ThemeContext = createContext<string>('light');
function Button({ children }: { children: React.ReactNode }) {
  const theme = useContext(ThemeContext);
  return <button className={theme}>{children}</button>;
}
```

---

## Phase 4 — Verify

After all changes:
1. Run `npm run typecheck` — fix TypeScript errors
2. Run `npm test` — fix failing tests
3. Run `npm run lint` — fix linting errors
4. Run `npm run build` — confirm build passes
5. Report: N files changed, N tests passing, build status
