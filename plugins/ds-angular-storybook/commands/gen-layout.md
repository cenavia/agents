---
description: >
  Generate layout system components and page templates for an Angular Design System. Use when building
  layout primitives (Container, Stack, Cluster, Grid, Sidebar), responsive SCSS utilities, fluid spacing
  helpers, or full page templates (Dashboard, Landing, Auth, Settings). Also use when existing layouts
  need container queries, fluid typography, or viewport-agnostic spacing.
---

# Generate Layout System

Generate a complete, responsive Angular layout system — primitives, utilities, and page templates.

## Input

Layout specification or template name: $ARGUMENTS

Examples:
- `/gen-layout` — generates the full layout primitive set
- `/gen-layout dashboard` — generates only the Dashboard page template
- `/gen-layout grid 12-col responsive` — generates a 12-column responsive grid system
- `/gen-layout stack cluster container` — generates specific primitives

---

## Step 1 — Read references

Before generating, read:
- `skills/responsive-design/references/breakpoint-strategies.md`
- `skills/responsive-design/references/container-queries.md`
- `skills/responsive-design/references/fluid-layouts.md`
- `skills/design-system-patterns/references/component-architecture.md`
- `skills/visual-design-foundations/references/spacing-iconography.md`

---

## Step 2 — Determine scope

If `$ARGUMENTS` is empty, generate the FULL layout system (all primitives + SCSS utilities).
If specific components or templates are named, generate only those.

---

## Step 3 — Generate layout primitives

Location: `projects/[ds-name]/src/lib/layout/`

### ContainerComponent (`ds-container`)

The foundation of every layout — centers content within a max-width constraint.

```typescript
// container.component.ts
export type ContainerSize = 'sm' | 'md' | 'lg' | 'xl' | '2xl' | 'full' | 'fluid';

@Component({
  selector: 'ds-container',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `<ng-content />`,
  styles: [`
    :host {
      display: block;
      width: 100%;
      margin-inline: auto;
      padding-inline: var(--container-padding);
    }
  `],
  host: {
    '[style.max-width]': 'maxWidth()',
    '[class]': 'classes()',
  }
})
export class DsContainerComponent {
  readonly size = input<ContainerSize>('xl');
  readonly centered = input<boolean>(true);
  readonly gutters = input<boolean>(true);

  readonly maxWidth = computed(() => {
    const map: Record<ContainerSize, string> = {
      sm: 'var(--container-sm)', md: 'var(--container-md)',
      lg: 'var(--container-lg)', xl: 'var(--container-xl)',
      '2xl': 'var(--container-2xl)', full: '100%', fluid: 'none',
    };
    return map[this.size()];
  });

  readonly classes = computed(() => ({
    'ds-container': true,
    'ds-container--no-center': !this.centered(),
    'ds-container--no-gutters': !this.gutters(),
  }));
}
```

### StackComponent (`ds-stack`)

Vertical arrangement with consistent spacing.

```typescript
export type SpaceKey = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '8' | '10' | '12' | '16' | '20';
export type StackAlign = 'start' | 'center' | 'end' | 'stretch';

// Template:
// <div [class]="classes()" [style.gap]="gapValue()"><ng-content /></div>

// gap maps '4' → 'var(--space-4)'
```

### ClusterComponent (`ds-cluster`)

Horizontal wrapping arrangement — for tag lists, button groups, navigation items.

```typescript
export type JustifyContent = 'start' | 'center' | 'end' | 'between' | 'around' | 'evenly';
export type AlignItems = 'start' | 'center' | 'end' | 'baseline' | 'stretch';

// display: flex; flex-wrap: wrap
// justify-content maps 'between' → 'space-between'
```

### GridComponent (`ds-grid`)

CSS Grid wrapper — supports fixed columns or responsive auto-fit.

```typescript
export type GridCols = 1 | 2 | 3 | 4 | 5 | 6 | 12 | 'auto-fit' | 'auto-fill';

// For fixed cols: grid-template-columns: repeat(N, 1fr)
// For auto-fit:   grid-template-columns: repeat(auto-fit, minmax(var(--min-col-width, 16rem), 1fr))
```

### SidebarLayoutComponent (`ds-sidebar-layout`)

Fixed-width sidebar + flexible main. Slots: `[sidebar]` and `[main]`.

```html
<!-- Template -->
<div [class]="classes()">
  <aside class="ds-sidebar-layout__sidebar">
    <ng-content select="[sidebar]" />
  </aside>
  <main class="ds-sidebar-layout__main">
    <ng-content select="[main]" />
  </main>
</div>
```

SCSS — stacks vertically below the `stackBelow` breakpoint using `@include respond-to()`.

### SplitComponent (`ds-split`)

Ratio-based horizontal split: `1:1`, `1:2`, `2:1`, `1:3`, `3:1`.

```scss
.ds-split { display: grid; gap: var(--space-#{$gap}); }
// Ratio maps: '1:2' → grid-template-columns: 1fr 2fr
```

---

## Step 4 — Generate SCSS layout utilities

Location: `projects/[ds-name]/src/lib/tokens/`

### `_responsive.scss`

```scss
@use 'sass:map';

$breakpoints: (
  'xs': 320px, 'sm': 480px, 'md': 768px,
  'lg': 1024px, 'xl': 1280px, '2xl': 1536px
) !default;

@mixin respond-to($bp) {
  @if map.has-key($breakpoints, $bp) {
    @media (min-width: #{map.get($breakpoints, $bp)}) { @content; }
  } @else {
    @warn 'Unknown breakpoint `#{$bp}`.';
  }
}

@mixin respond-below($bp) {
  @if map.has-key($breakpoints, $bp) {
    @media (max-width: calc(#{map.get($breakpoints, $bp)} - 1px)) { @content; }
  }
}

@mixin container-query($size) {
  @container (min-width: #{$size}) { @content; }
}
```

### `_fluid.scss`

```scss
// clamp-based fluid values between two viewport widths
@function fluid($min-val, $max-val, $min-vw: 320px, $max-vw: 1536px) {
  $slope: ($max-val - $min-val) / ($max-vw - $min-vw);
  $intercept: $min-val - $slope * $min-vw;
  @return clamp(#{$min-val}, #{$slope * 100vw + $intercept}, #{$max-val});
}

// Usage: font-size: fluid(1rem, 1.5rem);
// Usage: padding: fluid(1rem, 3rem);
```

---

## Step 5 — Generate page templates (if requested)

Location: `projects/[app-name]/src/app/templates/[template-name]/`

Each template is a standalone Angular component with full layout:

### DashboardPageTemplate

```
dashboard-page/
├── dashboard-page.component.ts     (standalone, routing wrapper)
├── dashboard-page.component.html   (uses ds-sidebar-layout, ds-container, ds-grid)
├── dashboard-page.component.scss   (only layout-specific overrides)
└── dashboard-page.stories.ts       (static mock story with placeholder cards)
```

HTML structure:
```html
<ds-sidebar-layout [sidebarWidth]="'280px'" stackBelow="md">
  <ng-container sidebar>
    <nav class="dashboard-nav"><!-- Navigation items --></nav>
  </ng-container>
  <ng-container main>
    <ds-container size="xl">
      <ds-stack gap="6">
        <header class="dashboard-header"><!-- Page title + actions --></header>
        <ds-grid cols="3" gap="4">
          <!-- KPI cards -->
          <ng-content />
        </ds-grid>
      </ds-stack>
    </ds-container>
  </ng-container>
</ds-sidebar-layout>
```

### LandingPageTemplate

Full-bleed sections using `ds-container` for inner centering:
```html
<section class="hero">
  <ds-container size="lg"><ds-stack><!-- Hero content --></ds-stack></ds-container>
</section>
<section class="features">
  <ds-container><ds-grid cols="auto-fit" minColWidth="280px" gap="6"><!-- Feature cards --></ds-grid></ds-container>
</section>
```

### AuthPageTemplate

Centered card with optional split layout:
```html
<div class="auth-layout">
  <aside class="auth-layout__panel" aria-hidden="true"><!-- Decorative --></aside>
  <main class="auth-layout__form">
    <ds-container size="sm"><ng-content /></ds-container>
  </main>
</div>
```

---

## Step 6 — Update public API and index.scss

Append to `projects/[ds-name]/src/public-api.ts`:
```typescript
export * from './lib/layout/container/container.component';
export * from './lib/layout/stack/stack.component';
export * from './lib/layout/cluster/cluster.component';
export * from './lib/layout/grid/grid.component';
export * from './lib/layout/sidebar-layout/sidebar-layout.component';
export * from './lib/layout/split/split.component';
```

Add to `projects/[ds-name]/src/lib/tokens/index.scss`:
```scss
@forward 'responsive';
@forward 'fluid';
```

---

## Step 7 — Validate

```bash
npx ng build [ds-name]
```

Fix any compilation errors before reporting done.

---

## Step 8 — Report

List:
- Every layout component created with its selector and key inputs
- Every SCSS utility file created with the mixins/functions it provides
- Any page templates created
- Next step: `/storybook-setup` to add viewport and container query stories
