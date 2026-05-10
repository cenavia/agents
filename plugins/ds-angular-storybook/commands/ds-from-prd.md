---
description: >
  Generate a complete Angular Design System from a PRD. Use when the user provides a Product Requirements
  Document (PRD), brand guidelines, or a feature brief and wants to generate the full DS: tokens, components,
  layouts, Storybook, and tests. This is the master command — it orchestrates all other DS generation commands.
---

# Generate Complete Design System from PRD

Generate a production-ready Angular Design System from end to end based on the provided PRD or brief.

## Input

PRD or brief provided by the user: $ARGUMENTS

If no arguments are provided, ask the user to either:
1. Paste the PRD content directly into the chat, or
2. Provide the file path to the PRD document.

---

## Phase 0 — Read and analyze

Before writing any code:

1. **Read the PRD** and extract these properties into a structured summary table:

| Property | Extracted value |
|----------|----------------|
| DS / Product name | |
| Brand primary color | |
| Brand secondary color | |
| Neutral palette | |
| Error / Warning / Success / Info colors | |
| Primary font family | |
| Monospace font | |
| Base font size | |
| Spacing philosophy (4px, 8px, custom) | |
| Component list needed | |
| Layout types | |
| Dark mode required | |
| Multi-brand required | |
| Distribution strategy (same app / library / npm) | |
| Angular version | |
| Accessibility level (A / AA / AAA) | |

2. **Determine the workspace strategy** based on distribution:
   - Single app → Strategy 1 (inline `src/design-system/`)
   - Multiple apps, same repo → **Strategy 2** (Angular Library) ← default
   - Multiple repos → Strategy 3 (npm private package)

3. **Confirm with the user** the extracted summary before proceeding. If anything is missing, ask only once with all questions grouped.

---

## Phase 1 — Workspace setup

Read `skills/angular-design-system-storybook/SKILL.md` and the corresponding strategy reference file before running CLI commands.

### Strategy 2 (default) — Angular Library

```bash
# 1. Create workspace
npx @angular/cli@latest new [ds-name]-workspace --no-create-application --style scss --skip-git

cd [ds-name]-workspace

# 2. Create the main application
ng generate application [app-name] --style scss --routing

# 3. Create the design system library
ng generate library [ds-name] --prefix ds --style scss

# 4. Install dependencies
npm install --save-dev \
  @storybook/angular \
  @storybook/addon-essentials \
  @storybook/addon-a11y \
  @storybook/addon-interactions \
  @storybook/addon-themes \
  @chromatic-com/storybook

# 5. Init Storybook
npx storybook@latest init --builder @storybook/angular --yes

# 6. Install Jest
npm install --save-dev jest @types/jest jest-preset-angular
```

---

## Phase 2 — Design Tokens

Delegate to the `token-engineer` agent with the full PRD context.

Generate in order:
1. `projects/[ds-name]/src/lib/tokens/_colors.scss` — primitive palette + semantic aliases
2. `projects/[ds-name]/src/lib/tokens/_typography.scss` — font scale and families
3. `projects/[ds-name]/src/lib/tokens/_spacing.scss` — 4px grid spacing + radii + max-widths
4. `projects/[ds-name]/src/lib/tokens/_shadows.scss` — elevation levels + focus rings
5. `projects/[ds-name]/src/lib/tokens/_motion.scss` — durations, easings, reduced-motion
6. `projects/[ds-name]/src/lib/tokens/_breakpoints.scss` — viewport breakpoints + container sizes
7. `projects/[ds-name]/src/lib/tokens/_z-index.scss` — named z-index layers
8. `projects/[ds-name]/src/lib/tokens/index.scss` — @forward all token files

Import tokens in `projects/[app-name]/src/styles.scss` and in `.storybook/preview.ts`.

---

## Phase 3 — Atom Components

For each atom below, use the `component-builder` agent to generate the full file set:

**Priority 1 (always generate):**
- `ds-button` (ButtonComponent)
- `ds-input` (InputComponent)
- `ds-badge` (BadgeComponent)
- `ds-spinner` (SpinnerComponent)

**Priority 2 (generate if in PRD component list):**
- `ds-checkbox` (CheckboxComponent)
- `ds-select` (SelectComponent)
- `ds-toggle` (ToggleComponent)
- `ds-tag` (TagComponent)
- `ds-icon` (IconComponent)
- `ds-divider` (DividerComponent)

For each component, create inside `projects/[ds-name]/src/lib/components/atoms/[name]/`:
- `[name].component.ts`
- `[name].component.html` (only if template > 5 lines)
- `[name].component.scss`
- `[name].component.spec.ts`
- `[name].stories.ts`

---

## Phase 4 — Molecule Components

For each molecule in the PRD component list, use `component-builder`:

**Default molecules (generate unless PRD excludes):**
- `ds-card` (CardComponent) — variant, padding, hoverable, clickable slots
- `ds-alert` (AlertComponent) — info/success/warning/error variants with dismiss
- `ds-toast` (ToastService + ToastComponent) — with portal/overlay injection

**Additional if in PRD:**
- `ds-modal` (ModalComponent + ModalService)
- `ds-tooltip` (TooltipDirective)
- `ds-dropdown` (DropdownComponent)
- `ds-tabs` (TabsComponent + TabComponent)
- `ds-accordion` (AccordionComponent + AccordionItemComponent)
- `ds-avatar` (AvatarComponent)

Location: `projects/[ds-name]/src/lib/components/molecules/[name]/`

---

## Phase 5 — Layout System

Use the `layout-engineer` agent to generate:

1. Layout primitive components in `projects/[ds-name]/src/lib/layout/`:
   - `ds-container`
   - `ds-stack`
   - `ds-cluster`
   - `ds-grid`
   - `ds-sidebar-layout`

2. SCSS layout utilities in `projects/[ds-name]/src/lib/tokens/`:
   - `_responsive.scss` (breakpoint mixins)
   - `_fluid.scss` (clamp helpers)

3. Page templates if specified in PRD, in `projects/[app-name]/src/app/templates/`:
   - Dashboard, Landing, Auth, Settings

---

## Phase 6 — Storybook configuration

Use the `storybook-specialist` agent to configure:
- `.storybook/main.ts`
- `.storybook/preview.ts`
- `.storybook/theme.ts`
- `stories/Introduction.mdx`
- `stories/DesignTokens.mdx`

---

## Phase 7 — Public API and exports

Update `projects/[ds-name]/src/public-api.ts` to export every component, directive, type, and service.

---

## Phase 8 — package.json scripts

Add these scripts to root `package.json`:

```json
{
  "start": "ng serve [app-name]",
  "build:ds": "ng build [ds-name]",
  "build:ds:watch": "ng build [ds-name] --watch",
  "storybook": "storybook dev -p 6006",
  "build:storybook": "storybook build -o dist/storybook",
  "test": "jest",
  "test:ds": "jest --projects=projects/[ds-name]",
  "test:ds:watch": "jest --projects=projects/[ds-name] --watch",
  "test:coverage": "jest --coverage",
  "test:ci": "jest --ci --coverage --runInBand"
}
```

---

## Phase 9 — Validation

Run these checks and fix any errors before reporting done:

```bash
npm run build:ds          # Must succeed with zero errors
npm run test:ci           # Must pass with ≥80% coverage
npm run build:storybook   # Must build without warnings
```

---

## Final output

Report to the user:
1. ✅ What was generated (files list, component count, token count)
2. 🚀 How to run: `npm run build:ds:watch` (T1), `npm run storybook` (T2), `npm run start` (T3)
3. 📋 What is NOT yet generated (organisms, optional components not in PRD)
4. 🔗 Next steps: `/ds-audit`, `/ds-publish`, adding organisms
