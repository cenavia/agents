---
description: Deep code review of React components, hooks, or files for correctness, performance, accessibility, and security. Usage: /react-dev-suite:review [file-path or description]
---

Perform a comprehensive React code review based on: $ARGUMENTS

## Instructions

If a file path is provided, read it first. If a description or "current file" is mentioned, read the current open file. If no argument is provided, ask the user which file or code to review.

For each file reviewed, run the following checklist and report every finding with file path, approximate line reference, severity, and corrected code.

---

## Review Checklist

### Correctness — React

- [ ] **Rules of Hooks** — no hooks inside conditions, loops, or nested functions
- [ ] **Dependency arrays** — all reactive values listed in `useEffect` / `useMemo` / `useCallback` deps
- [ ] **Missing cleanup** — `useEffect` with subscriptions, timers, event listeners, or fetch — cleanup present?
- [ ] **Stale closure** — `useEffect` capturing outdated values because deps are missing
- [ ] **Direct mutation** — `state.array.push()` or `state.obj.key = value` instead of returning new objects
- [ ] **Functional updates** — `setCount(count + 1)` inside async code → should be `setCount(c => c + 1)`
- [ ] **Derived state in useState** — values that can be computed from props/other state shouldn't be stored separately
- [ ] **Keys** — `key={index}` on dynamic/reorderable lists → use stable IDs
- [ ] **Conditional rendering safety** — `{count && <Comp />}` renders `0` — use `{count > 0 && <Comp />}`

### Correctness — TypeScript

- [ ] **`any` usage** — replace with `unknown` + type guards or proper types
- [ ] **Non-null assertion `!`** — justified? Or should it be a null check?
- [ ] **Unsafe `as` casts** — could hide runtime errors?
- [ ] **Missing return types** — exported functions and hook returns should be explicitly typed
- [ ] **`@ts-ignore` / `@ts-expect-error`** — explain why, or fix properly

### Performance

- [ ] **Inline objects/arrays in JSX** — `<Comp style={{ marginTop: 8 }} />` creates new ref each render
- [ ] **Inline callbacks to memoized children** — `<MemoComp onClick={() => fn(id)} />` defeats memo
- [ ] **Over-memoization** — `useMemo`/`useCallback` on trivial values without evidence of perf gain
- [ ] **Missing code splitting** — large components/pages not lazy-loaded
- [ ] **Long list without virtualization** — lists > 100 items rendered without `react-virtual` or similar
- [ ] **Sequential async in render/effect** — awaiting sequentially when `Promise.all` would work

### Accessibility (a11y)

- [ ] **Missing accessible name** — `<button><Icon /></button>` with no text/aria-label
- [ ] **Clickable div/span** — replace with `<button>` or add `role="button"`, `tabIndex={0}`, `onKeyDown`
- [ ] **Missing `alt`** — images without alt attribute (or `alt=""` for decorative)
- [ ] **Form labels** — every input paired with `<label htmlFor>` or `aria-label`
- [ ] **Error announcement** — validation errors should have `role="alert"`
- [ ] **`aria-invalid`** — set on inputs with validation errors
- [ ] **Focus management** — modals/drawers trap focus and restore it on close
- [ ] **Color-only indication** — errors shown only in red (no icon/text for colorblind users)
- [ ] **`tabIndex > 0`** — avoid; breaks natural tab order

### Security

- [ ] **`dangerouslySetInnerHTML`** — is the content sanitized with DOMPurify or similar?
- [ ] **Dynamic `href` / `src`** — constructed from user input without validation? (XSS via `javascript:`)
- [ ] **Sensitive data in state** — tokens, passwords visible in React DevTools
- [ ] **Hardcoded secrets** — API keys, credentials in source code

### Maintainability

- [ ] **Component size** — > 200 lines? Extract sub-components or hooks
- [ ] **Single responsibility** — does this component do more than one thing?
- [ ] **Prop drilling** — same prop passed > 2 levels deep? Consider Context or store
- [ ] **Magic values** — unexplained numbers/strings that should be named constants
- [ ] **Dead code** — commented-out code, unused imports, unreachable branches

---

## Output Format

### Summary
[Severity: Critical / Moderate / Minor only] — [1-2 sentence overall assessment]

### 🔴 Critical Issues (break functionality, security risk)
**[CRITICAL] [Category] — [file:line]**  
What's wrong + corrected code block

### 🟡 Moderate Issues (quality, performance, a11y)
**[MODERATE] [Category] — [file:line]**  
What's wrong + corrected code block or guidance

### 🔵 Minor Issues (style, cleanup)
Brief list with line references

### ✅ What's Done Well
[3-5 specific positive observations — helps developer know what to keep doing]
