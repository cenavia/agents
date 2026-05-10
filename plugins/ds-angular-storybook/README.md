# contex-ds — Angular Design System Plugin

A Claude Code plugin for generating and managing enterprise-grade Angular Design Systems with Storybook.

**Core idea**: give it a PRD → it generates everything, from design tokens to a full component library to page templates.

---

## What it generates

From a single PRD or brand brief:

| Layer | What's created |
|-------|---------------|
| **Tokens** | Colors (3-layer), Typography scale, 4px Spacing grid, Shadows, Motion, Breakpoints, Z-index |
| **Atoms** | Button, Input, Select, Checkbox, Badge, Spinner, Icon, Tag, Divider |
| **Molecules** | Card, Modal, Alert, Toast, Dropdown, Tabs, Accordion, Avatar |
| **Organisms** | Header, Sidebar, DataTable, Form, PageHero |
| **Layout** | Container, Stack, Cluster, Grid, SidebarLayout, Split + page templates |
| **Storybook** | Full config, custom theme, global dark-mode toggle, MDX docs, Chromatic CI |
| **Tests** | Jest suite per component, 80%+ coverage target |

---

## Quick start

```bash
# Load the plugin
claude --plugin-dir /path/to/contex-DS-angular-storybook

# Generate complete DS from a PRD
/ds-from-prd path/to/my-product-prd.md

# Or provide brand info directly
/ds-from-prd Brand: Acme Corp. Primary: #0EA5E9. Font: Inter. Need: Dashboard app with data tables.
```

---

## Slash commands

| Command | What it does |
|---------|-------------|
| `/contex-ds:ds-from-prd [prd]` | **Master command** — generates the full DS from a PRD |
| `/contex-ds:gen-tokens [brand info]` | Generates all 7 token files (colors, type, spacing, shadows…) |
| `/contex-ds:gen-component [name]` | Generates a single component with story, spec, and SCSS |
| `/contex-ds:gen-layout [spec]` | Generates layout primitives and/or page templates |
| `/contex-ds:storybook-setup [focus]` | Configures Storybook with addons, theme, and MDX docs |
| `/contex-ds:ds-audit [focus]` | Audits DS for token violations, missing a11y, gaps |
| `/contex-ds:ds-publish [version]` | Packages and publishes the DS to npm |

---

## Agents

| Agent | Role |
|-------|------|
| `design-system-architect` | Analyzes PRD → produces architecture plan + directory tree |
| `token-engineer` | Generates all SCSS token files with 3-layer model |
| `component-builder` | Builds standalone Angular components with stories + tests |
| `layout-engineer` | Creates layout primitives, responsive utilities, page templates |
| `storybook-specialist` | Configures Storybook, addons, themes, MDX documentation |

---

## Skills bundled

| Skill | Domain |
|-------|--------|
| `angular-design-system-storybook` | Angular Library setup, tokens, Storybook, Jest |
| `design-system-patterns` | Token architecture, component patterns, theming |
| `visual-design-foundations` | Color systems, typography, spacing methodology |
| `responsive-design` | Breakpoints, container queries, fluid layouts |
| `accessibility-compliance` | WCAG 2.1 AA, ARIA patterns, mobile accessibility |
| `interaction-design` | Animation libraries, microinteractions, scroll patterns |
| `web-component-design` | Component CSS patterns, accessibility, styling approaches |

---

## Development workflow (after generation)

Run three terminals in parallel:

```bash
# Terminal 1 — compile the library in watch mode
npm run build:ds:watch

# Terminal 2 — Storybook catalog at http://localhost:6006
npm run storybook

# Terminal 3 — Main application at http://localhost:4200
npm run start
```

---

## Architecture: 3-layer token model

```
Layer 1 (Primitive)   →   Layer 2 (Semantic)   →   Layer 3 (Component)
--blue-500: #3B82F6       --color-brand: var()      --btn-bg: var()
--neutral-900: #0F172A    --color-text-primary: var() (in component SCSS)
```

Components ONLY use Layer 2 tokens. Layer 1 is never referenced in component SCSS.

---

## Component architecture

Every component follows this pattern:

```typescript
@Component({
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DsButtonComponent {
  readonly variant = input<ButtonVariant>('primary');  // signal inputs
  readonly classes = computed(() => ({ ... }));        // computed classes
}
```

- `standalone: true` always
- `input()` signal API (Angular 17+), never `@Input()` decorator
- `inject()` for DI, never constructor injection
- `computed()` for derived class objects
- `ControlValueAccessor` for all form components

---

## License

MIT
