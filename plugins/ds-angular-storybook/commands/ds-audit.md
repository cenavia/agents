---
description: >
  Audit an existing Angular Design System for quality, consistency, and coverage issues. Use when reviewing
  a DS for token usage violations (hardcoded values), missing ARIA attributes, incomplete test coverage,
  missing Storybook stories, inconsistent naming conventions, public API gaps, or outdated dependencies.
  Produces a prioritized issue report with recommended fixes.
---

# Design System Audit

Perform a comprehensive quality audit of the Angular Design System and produce a prioritized issue report.

## Input

Optional focus area: $ARGUMENTS

Examples:
- `/ds-audit` — full audit
- `/ds-audit tokens` — only audit token usage
- `/ds-audit accessibility` — only audit ARIA and WCAG compliance
- `/ds-audit coverage` — only audit test coverage
- `/ds-audit stories` — only audit Storybook completeness

---

## Step 1 — Discover DS structure

```bash
# Find the DS library root
find . -name "public-api.ts" -not -path "*/node_modules/*"

# List all components
find projects/*/src/lib/components -name "*.component.ts" -not -path "*/node_modules/*"

# List all token files
find projects/*/src/lib/tokens -name "*.scss" -not -path "*/node_modules/*"

# List all stories
find projects -name "*.stories.ts" -not -path "*/node_modules/*"

# List all spec files
find projects -name "*.spec.ts" -not -path "*/node_modules/*"
```

---

## Step 2 — Token audit

### 2a. Hardcoded value scan

Search for hardcoded CSS values that should be tokens:

```bash
# Hardcoded colors (hex, rgb, hsl)
grep -rn --include="*.scss" \
  -E "(#[0-9a-fA-F]{3,8}|rgb\(|rgba\(|hsl\(|hsla\()" \
  projects/*/src/lib/components/ \
  | grep -v "\.spec\." | grep -v "stories"

# Hardcoded pixel values > 0px (not in tokens)
grep -rn --include="*.scss" \
  -E "[^-]([0-9]+px)" \
  projects/*/src/lib/components/ \
  | grep -v "\.spec\." | grep -v "1px\|0px"

# Hardcoded font sizes
grep -rn --include="*.scss" \
  -E "font-size:\s*[0-9]" \
  projects/*/src/lib/components/
```

### 2b. Token naming consistency

Check for tokens that don't follow the `--[category]-[scale]-[variant]` pattern:

```bash
grep -rn --include="*.scss" \
  -E "var\(--[a-zA-Z]" \
  projects/*/src/lib/components/ \
  | grep -vE "var\(--(color|text|font|leading|tracking|space|radius|shadow|ring|duration|ease|z|container|brand|neutral|red|green|yellow|blue)-"
```

### 2c. Undefined token usage

Find `var(--token)` references that aren't defined in token files:

```bash
# Extract all used token names
grep -roh --include="*.scss" "var(--[a-zA-Z0-9_-]*)" projects/ | sort -u > /tmp/used-tokens.txt

# Extract all defined token names
grep -roh --include="*.scss" "--[a-zA-Z0-9_-]*:" projects/*/src/lib/tokens/ | sed 's/://' | sort -u > /tmp/defined-tokens.txt

# Find undefined (used but not defined)
comm -23 /tmp/used-tokens.txt /tmp/defined-tokens.txt
```

---

## Step 3 — Component audit

### 3a. Missing standalone decorator

```bash
grep -rL "standalone: true" projects/*/src/lib/components/**/*.component.ts 2>/dev/null
```

### 3b. Hardcoded change detection (missing OnPush)

```bash
grep -rL "ChangeDetectionStrategy.OnPush" projects/*/src/lib/components/**/*.component.ts 2>/dev/null
```

### 3c. Constructor injection (should use inject())

```bash
grep -rn "constructor(" projects/*/src/lib/components/**/*.component.ts 2>/dev/null \
  | grep -v "//\|spec\|stories" | grep -v "constructor()"
```

### 3d. @Input() decorator usage (should use input() signal)

```bash
grep -rn "@Input()" projects/*/src/lib/components/ 2>/dev/null | grep "\.component\.ts"
```

### 3e. Missing ControlValueAccessor for form components

```bash
# Find input/select/checkbox/toggle/radio components without CVA
for comp in input select checkbox toggle radio; do
  result=$(find projects -name "${comp}.component.ts" | xargs grep -L "ControlValueAccessor" 2>/dev/null)
  [ -n "$result" ] && echo "Missing CVA: $result"
done
```

### 3f. Public API gaps

Find components exported from `lib/` but missing from `public-api.ts`:

```bash
# Components in lib
grep -roh --include="*.component.ts" "export class Ds[A-Za-z]*Component" projects/*/src/lib/ | sed 's/.*export class //' | sort > /tmp/lib-components.txt

# Components in public-api.ts  
grep -oh "Ds[A-Za-z]*Component" projects/*/src/public-api.ts | sort > /tmp/api-components.txt

comm -23 /tmp/lib-components.txt /tmp/api-components.txt
```

---

## Step 4 — Accessibility audit

### 4a. Interactive elements without labels

```bash
# Buttons without text or aria-label
grep -rn --include="*.html" "<button" projects/*/src/lib/components/ \
  | grep -v "aria-label\|>.*</button>"

# Images without alt text
grep -rn --include="*.html" "<img" projects/*/src/lib/components/ \
  | grep -v "alt="
```

### 4b. Form elements without labels

```bash
grep -rn --include="*.html" "<input\|<select\|<textarea" projects/*/src/lib/components/ \
  | grep -v "aria-label\|aria-labelledby\|\[for\]"
```

### 4c. Missing focus-visible styles

```bash
grep -rL "focus-visible" projects/*/src/lib/components/**/*.scss 2>/dev/null \
  | grep -v "spec\|stories"
```

### 4d. Color contrast (requires manual review)

List all places where `--color-text-*` and `--color-bg-*` are combined and note for manual Lighthouse check.

---

## Step 5 — Storybook audit

### 5a. Components without stories

```bash
for comp_file in $(find projects/*/src/lib/components -name "*.component.ts" | grep -v spec); do
  dir=$(dirname "$comp_file")
  name=$(basename "$comp_file" .component.ts)
  stories_file="${dir}/${name}.stories.ts"
  [ ! -f "$stories_file" ] && echo "Missing stories: $stories_file"
done
```

### 5b. Stories missing autodocs tag

```bash
grep -rL "tags: \['autodocs'\]" projects/*/src/lib/components/**/*.stories.ts 2>/dev/null
```

### 5c. Stories missing required story types (AllVariants, States)

```bash
for req in "AllVariants" "States"; do
  grep -rL "export const ${req}" projects/*/src/lib/components/**/*.stories.ts 2>/dev/null \
    | sed "s/^/Missing '${req}' story: /"
done
```

---

## Step 6 — Test coverage audit

```bash
npx jest --coverage --coverageReporters=text-summary 2>/dev/null | tail -20
```

Also check for components with no spec file:

```bash
for comp_file in $(find projects/*/src/lib/components -name "*.component.ts" | grep -v spec); do
  dir=$(dirname "$comp_file")
  name=$(basename "$comp_file" .component.ts)
  spec_file="${dir}/${name}.component.spec.ts"
  [ ! -f "$spec_file" ] && echo "Missing spec: $spec_file"
done
```

---

## Step 7 — Dependency audit

```bash
npx npm-check-updates --packageFile package.json 2>/dev/null || npm outdated
```

---

## Step 8 — Compile audit report

Output a structured report:

```
# Design System Audit Report
Date: [today]
Version: [from package.json]

## Summary
| Category | Issues found | Critical | Warnings |
|----------|-------------|----------|----------|
| Tokens | | | |
| Components | | | |
| Accessibility | | | |
| Storybook | | | |
| Tests | | | |
| Dependencies | | | |

## Critical Issues (fix immediately)
[List with file:line references]

## Warnings (fix before next release)
[List]

## Recommendations (best effort)
[List]

## Fix commands
- Run `/gen-tokens` to add missing tokens
- Run `/gen-component [name]` to add missing stories/specs
- Run `/storybook-setup` to fix Storybook configuration
```

Prioritize: Critical > Warnings > Recommendations. Never mark more than 5 items as Critical.
