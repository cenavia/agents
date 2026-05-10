---
description: Run a full React codebase audit with grep scans for deprecated APIs, anti-patterns, and migration blockers. Usage: /react-dev-suite:audit [target: react-19|react-18|all|a11y|perf|security]
---

Run a comprehensive React codebase audit based on: $ARGUMENTS

## Instructions

Parse the target scope (default: `all`):
- `react-19` — scan for React 19 breaking changes and removals
- `react-18` — scan for React 18 migration blockers
- `all` — run complete audit (deprecated APIs + patterns + a11y + perf + security + architecture)
- `a11y` — accessibility audit only
- `perf` — performance anti-patterns only
- `security` — security issues only
- `architecture` — folder structure consistency audit (reads `architecture` from `.rds-context.json`)

Detect the project `src/` directory. If not found, look for `app/`, `lib/`, or ask the user.

---

## Audit Scans

### 1. React Version Migration Blockers

```bash
# React 18 blockers
grep -rn "ReactDOM\.render\|ReactDOM\.hydrate" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null

# React 19 removals
grep -rn "createFactory\|React\.createFactory" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null
grep -rn "\.defaultProps\s*=" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null
grep -rn "propTypes\s*=" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null

# Unsafe lifecycles (React 17 warnings, React 19 removed)
grep -rn "componentWillMount\|componentWillUpdate\|componentWillReceiveProps" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null
grep -rn "UNSAFE_componentWill" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null

# String refs (removed React 19)
grep -rn 'ref="[^"]*"' src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null
grep -rn "this\.refs\." src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null

# Legacy context API
grep -rn "contextTypes\|childContextTypes\|getChildContext" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null

# act() import location (must be 'react' in React 19)
grep -rn "from 'react-dom/test-utils'" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null

# forwardRef (optional migration for React 19)
grep -rn "React\.forwardRef\|forwardRef(" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null | wc -l
```

### 2. React Anti-patterns

```bash
# key={index} in dynamic lists — not all are bad, flag for review
grep -rn "key={index}\|key={i}\|key={idx}" src/ --include="*.{jsx,tsx}" 2>/dev/null

# Conditional rendering of 0 (renders the number 0)
grep -rn "{[a-zA-Z]* &&" src/ --include="*.{jsx,tsx}" 2>/dev/null

# Direct state mutation patterns
grep -rn "\.push(\|\.splice(\|\.sort(\|\.reverse(" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null | grep -v "test\|spec\|mock"

# useEffect without deps array (runs on every render)
grep -rn "useEffect(" src/ --include="*.{js,jsx,ts,tsx}" -A2 2>/dev/null | grep -v "\[\|deps"
```

### 3. TypeScript Quality

```bash
# any usage
grep -rn ": any\|as any\|<any>" src/ --include="*.{ts,tsx}" 2>/dev/null | grep -v "test\|spec"

# Non-null assertions
grep -rn "!\." src/ --include="*.{ts,tsx}" 2>/dev/null | wc -l

# ts-ignore / ts-expect-error
grep -rn "@ts-ignore\|@ts-expect-error" src/ --include="*.{ts,tsx}" 2>/dev/null

# Implicit any in function params
grep -rn "function.*([^:]*)" src/ --include="*.{ts,tsx}" 2>/dev/null | grep -v "test\|import" | head -20
```

### 4. Accessibility Patterns

```bash
# Clickable divs/spans without role
grep -rn "<div.*onClick\|<span.*onClick" src/ --include="*.{jsx,tsx}" 2>/dev/null

# Images without alt
grep -rn "<img" src/ --include="*.{jsx,tsx}" 2>/dev/null | grep -v "alt="

# Buttons/inputs without accessible name (common patterns)
grep -rn "<button[^>]*>" src/ --include="*.{jsx,tsx}" -A1 2>/dev/null | grep -v "aria-label\|children\|[A-Za-z]" | head -20

# tabIndex > 0
grep -rn "tabIndex=[{\"'][1-9]" src/ --include="*.{jsx,tsx}" 2>/dev/null

# dangerouslySetInnerHTML (requires sanitization check)
grep -rn "dangerouslySetInnerHTML" src/ --include="*.{jsx,tsx}" 2>/dev/null
```

### 5. Performance Anti-patterns

```bash
# Inline object/array as prop (creates new ref each render)
grep -rn "={{[^}]*}}\|={\[" src/ --include="*.{jsx,tsx}" 2>/dev/null | grep -v "className\|style=\|test" | head -20

# Enzyme (should be migrated to RTL)
grep -rn "from 'enzyme'\|require('enzyme')" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null
```

### 6. Architecture Consistency

First, read the declared architecture:
```bash
cat .rds-context.json 2>/dev/null | grep architecture
```

Then run the appropriate checks:

#### For architecture: screaming or modular — cross-feature import violations
```bash
# Imports from another feature's internal files (bypassing index.ts)
grep -rn "from.*features/[^/]*/[^'\"]*'" src/ --include="*.{ts,tsx}" 2>/dev/null \
  | grep -v "index" | grep "features/" | grep "features/" \
  | awk -F: '{print $1}' | sort -u

# Direct cross-feature imports (feature A importing feature B's internals)
grep -rn "from '@/features/" src/features/ --include="*.{ts,tsx}" 2>/dev/null \
  | grep -v "index'" | grep -v "index\""
```

#### For architecture: screaming — code that belongs in shared/ but is duplicated across features
```bash
# Same component or hook name in multiple features (candidate for shared/)
find src/features -name "*.tsx" -o -name "*.ts" | xargs basename -a | sort | uniq -d 2>/dev/null
```

#### For architecture: file-type — feature code mixed into wrong directories
```bash
# Services outside src/services/ (for file-type architecture)
find src/ -name "*Service.ts" -o -name "*service.ts" 2>/dev/null | grep -v "src/services/"

# Hooks outside src/hooks/ (for file-type architecture)
find src/ -name "use*.ts" 2>/dev/null | grep -v "src/hooks/\|test\|spec"
```

#### For architecture: atomic — misplaced component levels
```bash
# Check for atoms that import organisms (violates atomic hierarchy)
grep -rn "from.*organisms" src/components/atoms/ --include="*.{ts,tsx}" 2>/dev/null
grep -rn "from.*molecules" src/components/atoms/ --include="*.{ts,tsx}" 2>/dev/null

# Components outside the atoms/molecules/organisms hierarchy
find src/components/ -maxdepth 1 -name "*.tsx" 2>/dev/null
```

#### General — missing index.ts barrel exports (applies to all architectures)
```bash
# Feature directories without an index.ts
for dir in src/features/*/; do
  [ ! -f "${dir}index.ts" ] && echo "Missing index.ts: $dir"
done 2>/dev/null

# Shared UI components without index.ts
for dir in src/shared/ui/*/; do
  [ ! -f "${dir}index.ts" ] && echo "Missing index.ts: $dir"
done 2>/dev/null
```

### 7. Security

```bash
# dangerouslySetInnerHTML without sanitization check
grep -rn "dangerouslySetInnerHTML" src/ --include="*.{jsx,tsx}" 2>/dev/null | grep -v "DOMPurify\|sanitize"

# Dynamic hrefs from variables
grep -rn 'href={' src/ --include="*.{jsx,tsx}" 2>/dev/null | grep -v '"\|`/' | head -10

# console.log with potential sensitive data
grep -rn "console\.(log|warn|error)" src/ --include="*.{js,jsx,ts,tsx}" 2>/dev/null | grep -v "test\|spec" | head -10
```

---

## Report Format

Run ALL relevant scans, then produce:

### Audit Report — [Project Name] — [Date]

**Scan target:** `src/` | **Scope:** `$ARGUMENTS`

#### Summary Table
| Category | Issues Found | Severity |
|---|---|---|
| React migration blockers | N | 🔴 Critical |
| React anti-patterns | N | 🟡 Moderate |
| TypeScript quality | N | 🟡 Moderate |
| Accessibility | N | 🟡 Moderate |
| Performance | N | 🔵 Minor |
| Architecture consistency | N | 🟡 Moderate |
| Security | N | 🔴 Critical |

#### Findings (grouped by category)

For each finding:
- File path and line number
- What the grep found
- Why it's a problem
- Recommended fix (with code example if non-obvious)

#### Migration Readiness (if applicable)
- React 18 ready: ✅ / ❌ (N blockers)
- React 19 ready: ✅ / ❌ (N blockers)

#### Recommended Next Steps
Prioritized action list (top 5 things to fix first)
