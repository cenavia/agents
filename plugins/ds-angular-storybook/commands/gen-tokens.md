---
description: >
  Generate design tokens for an Angular Design System. Use when the user wants to create or update token files
  — color palette, typography scale, spacing system, shadows, motion, breakpoints — from a PRD, brand
  guidelines, hex colors, Figma values, or a verbal description of the visual style.
---

# Generate Design Tokens

Generate a complete, production-ready token system as SCSS custom properties.

## Input

Brand guidelines, PRD excerpt, or token specification: $ARGUMENTS

If no arguments are provided, ask the user for:
1. Primary brand color (hex)
2. Secondary/accent color (if any)
3. Neutral palette preference (warm, cool, slate, or auto-generate)
4. Primary font family (Google Fonts name, system font, or custom)
5. Base font size (default: 16px)
6. Dark mode required? (yes/no)
7. Where to place token files (path in project)

---

## Step 1 — Read references

Before generating, read:
- `skills/visual-design-foundations/references/color-systems.md`
- `skills/visual-design-foundations/references/typography-systems.md`
- `skills/visual-design-foundations/references/spacing-iconography.md`
- `skills/design-system-patterns/references/design-tokens.md`
- `skills/design-system-patterns/references/theming-architecture.md`
- `skills/responsive-design/references/breakpoint-strategies.md`

---

## Step 2 — Determine token file location

Check if an Angular Library exists:
- Library found → `projects/[ds-name]/src/lib/tokens/`
- No library → `src/design-system/tokens/`
- Custom path provided → use it

---

## Step 3 — Generate token files

Generate ALL of the following files (do not skip any):

### `_colors.scss`

Three-layer structure:
```scss
// === LAYER 1: Primitive palette ===
// Auto-generate a 50–950 shade scale from the brand primary hex
:root {
  // Brand shades (generate 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950)
  --brand-50:  [lightest]; /* ... */
  --brand-500: [base];
  --brand-900: [darkest];

  // Neutral shades (slate by default unless user specifies warm/cool)
  --neutral-50: ...;
  // ... through --neutral-950

  // Semantic status colors (error, warning, success, info — always use standard hues)
  --red-500:    #EF4444;
  --yellow-500: #F59E0B;
  --green-500:  #22C55E;
  --blue-500:   #3B82F6;

  // === LAYER 2: Semantic aliases ===
  --color-brand:          var(--brand-500);
  --color-brand-hover:    var(--brand-600);
  --color-brand-active:   var(--brand-700);
  --color-brand-subtle:   var(--brand-50);

  --color-bg-primary:     #FFFFFF;
  --color-bg-secondary:   var(--neutral-50);
  --color-bg-tertiary:    var(--neutral-100);
  --color-bg-inverse:     var(--neutral-900);

  --color-text-primary:   var(--neutral-900);
  --color-text-secondary: var(--neutral-600);
  --color-text-muted:     var(--neutral-400);
  --color-text-inverse:   #FFFFFF;
  --color-text-disabled:  var(--neutral-300);

  --color-border:         var(--neutral-200);
  --color-border-strong:  var(--neutral-300);

  --color-error:          var(--red-500);
  --color-error-subtle:   #FEF2F2;
  --color-success:        var(--green-500);
  --color-success-subtle: #F0FDF4;
  --color-warning:        var(--yellow-500);
  --color-warning-subtle: #FFFBEB;
  --color-info:           var(--blue-500);
  --color-info-subtle:    #EFF6FF;
}

// Dark mode overrides (semantic tokens only)
[data-theme="dark"],
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --color-bg-primary:     var(--neutral-950);
    --color-bg-secondary:   var(--neutral-900);
    --color-bg-tertiary:    var(--neutral-800);
    --color-text-primary:   var(--neutral-50);
    --color-text-secondary: var(--neutral-300);
    --color-text-muted:     var(--neutral-500);
    --color-border:         var(--neutral-800);
    --color-border-strong:  var(--neutral-700);
    /* ... */
  }
}
```

### `_typography.scss`

```scss
:root {
  // Font families
  --font-sans:    'Inter', system-ui, -apple-system, sans-serif;
  --font-serif:   'Playfair Display', Georgia, serif; /* if needed */
  --font-mono:    'JetBrains Mono', 'Fira Code', monospace;

  // Type scale (major third = 1.25 ratio from 16px base)
  --text-xs:   0.75rem;    /* 12px */
  --text-sm:   0.875rem;   /* 14px */
  --text-base: 1rem;       /* 16px */
  --text-lg:   1.125rem;   /* 18px */
  --text-xl:   1.25rem;    /* 20px */
  --text-2xl:  1.5rem;     /* 24px */
  --text-3xl:  1.875rem;   /* 30px */
  --text-4xl:  2.25rem;    /* 36px */
  --text-5xl:  3rem;       /* 48px */

  // Font weights
  --font-light:     300;
  --font-normal:    400;
  --font-medium:    500;
  --font-semibold:  600;
  --font-bold:      700;
  --font-extrabold: 800;

  // Line heights
  --leading-none:    1;
  --leading-tight:   1.25;
  --leading-snug:    1.375;
  --leading-normal:  1.5;
  --leading-relaxed: 1.625;
  --leading-loose:   2;

  // Letter spacing
  --tracking-tighter: -0.05em;
  --tracking-tight:   -0.025em;
  --tracking-normal:  0em;
  --tracking-wide:    0.025em;
  --tracking-wider:   0.05em;
  --tracking-widest:  0.1em;
}
```

### `_spacing.scss`

```scss
:root {
  // Base: 4px grid
  --space-px:  1px;
  --space-0:   0;
  --space-0_5: 0.125rem;  /* 2px */
  --space-1:   0.25rem;   /* 4px */
  --space-1_5: 0.375rem;  /* 6px */
  --space-2:   0.5rem;    /* 8px */
  --space-2_5: 0.625rem;  /* 10px */
  --space-3:   0.75rem;   /* 12px */
  --space-4:   1rem;      /* 16px */
  --space-5:   1.25rem;   /* 20px */
  --space-6:   1.5rem;    /* 24px */
  --space-7:   1.75rem;   /* 28px */
  --space-8:   2rem;      /* 32px */
  --space-10:  2.5rem;    /* 40px */
  --space-12:  3rem;      /* 48px */
  --space-16:  4rem;      /* 64px */
  --space-20:  5rem;      /* 80px */
  --space-24:  6rem;      /* 96px */

  // Border radii
  --radius-none: 0;
  --radius-sm:   0.125rem;   /* 2px */
  --radius-md:   0.375rem;   /* 6px */
  --radius-lg:   0.5rem;     /* 8px */
  --radius-xl:   0.75rem;    /* 12px */
  --radius-2xl:  1rem;       /* 16px */
  --radius-3xl:  1.5rem;     /* 24px */
  --radius-full: 9999px;

  // Container max-widths
  --container-xs:  20rem;    /* 320px */
  --container-sm:  40rem;    /* 640px */
  --container-md:  48rem;    /* 768px */
  --container-lg:  64rem;    /* 1024px */
  --container-xl:  80rem;    /* 1280px */
  --container-2xl: 96rem;    /* 1536px */
  --container-padding: var(--space-4);
}
```

### `_shadows.scss`

```scss
:root {
  --shadow-none: none;
  --shadow-xs:   0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-sm:   0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  --shadow-md:   0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg:   0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl:   0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  --shadow-2xl:  0 25px 50px -12px rgb(0 0 0 / 0.25);
  --shadow-inner: inset 0 2px 4px 0 rgb(0 0 0 / 0.05);

  // Focus rings (2px solid + 2px offset = WCAG AA compliant)
  --ring-brand:   0 0 0 2px var(--color-bg-primary), 0 0 0 4px var(--color-brand);
  --ring-error:   0 0 0 2px var(--color-bg-primary), 0 0 0 4px var(--color-error);
  --ring-success: 0 0 0 2px var(--color-bg-primary), 0 0 0 4px var(--color-success);
  --ring-neutral: 0 0 0 2px var(--color-bg-primary), 0 0 0 4px var(--neutral-400);
}
```

### `_motion.scss`

```scss
:root {
  --duration-instant: 0ms;
  --duration-fast:    150ms;
  --duration-normal:  250ms;
  --duration-slow:    400ms;
  --duration-slower:  700ms;

  --ease-linear:      linear;
  --ease-in:          cubic-bezier(0.4, 0, 1, 1);
  --ease-out:         cubic-bezier(0, 0, 0.2, 1);
  --ease-in-out:      cubic-bezier(0.4, 0, 0.2, 1);
  --ease-spring:      cubic-bezier(0.34, 1.56, 0.64, 1);
  --ease-bounce:      cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

@media (prefers-reduced-motion: reduce) {
  :root {
    --duration-fast:   0.01ms;
    --duration-normal: 0.01ms;
    --duration-slow:   0.01ms;
    --duration-slower: 0.01ms;
  }
}
```

### `_z-index.scss`

```scss
:root {
  --z-below:    -1;
  --z-base:      0;
  --z-raised:    1;
  --z-dropdown:  10;
  --z-sticky:    20;
  --z-overlay:   30;
  --z-modal:     40;
  --z-popover:   50;
  --z-toast:     60;
  --z-tooltip:   70;
  --z-max:       9999;
}
```

### `_breakpoints.scss`

```scss
// SCSS map (for @include respond-to())
$breakpoints: (
  'xs':  320px,
  'sm':  480px,
  'md':  768px,
  'lg':  1024px,
  'xl':  1280px,
  '2xl': 1536px
) !default;

@mixin respond-to($bp) {
  @if map.has-key($breakpoints, $bp) {
    @media (min-width: map.get($breakpoints, $bp)) { @content; }
  } @else {
    @warn "Unknown breakpoint: #{$bp}";
  }
}
```

### `index.scss`

```scss
@forward 'breakpoints';
@forward 'colors';
@forward 'typography';
@forward 'spacing';
@forward 'shadows';
@forward 'motion';
@forward 'z-index';
```

---

## Step 4 — Validate

After generating, run a quick check:
```bash
npx sass --no-source-map projects/[ds-name]/src/lib/tokens/index.scss /dev/null
```
Fix any SCSS compilation errors before reporting done.

---

## Step 5 — Report

List every file generated, the number of tokens per category, and next suggested command:
- Run `/gen-component ds-button` to start building components
- Run `/storybook-setup` to configure the Storybook token preview
