---
description: >
  Configure Storybook for an Angular Design System project. Use when setting up Storybook from scratch,
  adding essential addons (a11y, interactions, designs, themes, chromatic), creating a custom Storybook
  theme matching the DS brand, writing MDX documentation pages (Introduction, Design Tokens), configuring
  global decorators for dark mode toggle, or troubleshooting Storybook Angular builds.
---

# Configure Storybook for Angular Design System

Set up a complete, production-ready Storybook catalog for the Angular DS.

## Input

Optional configuration focus: $ARGUMENTS

Examples:
- `/storybook-setup` — full setup from scratch
- `/storybook-setup addons` — only install and configure addons
- `/storybook-setup theme` — only create the custom Storybook UI theme
- `/storybook-setup docs` — only create MDX documentation pages
- `/storybook-setup chromatic` — only configure Chromatic CI integration

---

## Step 1 — Read references

Before generating configuration, read:
- `skills/angular-design-system-storybook/SKILL.md` — Storybook conventions for this DS

---

## Step 2 — Install Storybook (if not already installed)

Check if `.storybook/` directory exists. If not:

```bash
npx storybook@latest init --builder @storybook/angular --yes
```

Then install all recommended addons:

```bash
npm install --save-dev \
  @storybook/addon-essentials \
  @storybook/addon-a11y \
  @storybook/addon-interactions \
  @storybook/addon-designs \
  @storybook/addon-themes \
  @chromatic-com/storybook \
  @storybook/theming
```

---

## Step 3 — Configure `.storybook/main.ts`

```typescript
import type { StorybookConfig } from '@storybook/angular';

const config: StorybookConfig = {
  stories: [
    '../stories/**/*.mdx',
    '../projects/**/*.stories.@(js|ts)',
    '../projects/**/*.mdx',
  ],
  addons: [
    '@storybook/addon-essentials',
    '@storybook/addon-a11y',
    '@storybook/addon-interactions',
    '@storybook/addon-designs',
    '@storybook/addon-themes',
    '@chromatic-com/storybook',
  ],
  framework: {
    name: '@storybook/angular',
    options: {},
  },
  docs: {
    autodocs: 'tag',
    defaultName: 'Documentation',
  },
  staticDirs: ['../public'],
  core: {
    disableTelemetry: true,
  },
};
export default config;
```

---

## Step 4 — Configure `.storybook/preview.ts`

Read the token file path first:
```bash
find projects -path "*/tokens/index.scss" -not -path "*/node_modules/*"
```

Then generate:

```typescript
import type { Preview } from '@storybook/angular';
import '../projects/[ds-name]/src/lib/tokens/index.scss';
// Also import any global font imports
// import '../projects/[app-name]/src/styles.scss';

const preview: Preview = {
  parameters: {
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/,
      },
    },
    a11y: {
      config: {
        rules: [
          { id: 'color-contrast', enabled: true },
          { id: 'button-name', enabled: true },
          { id: 'image-alt', enabled: true },
          { id: 'label', enabled: true },
          { id: 'link-name', enabled: true },
        ],
      },
    },
    backgrounds: {
      default: 'light',
      values: [
        { name: 'light', value: '#FFFFFF' },
        { name: 'surface', value: '#F8FAFC' },
        { name: 'dark', value: '#0F172A' },
        { name: 'brand', value: '#1D4ED8' },
      ],
    },
    viewport: {
      viewports: {
        mobile_sm: { name: 'Mobile S', styles: { width: '320px', height: '568px' } },
        mobile:    { name: 'Mobile',   styles: { width: '375px', height: '812px' } },
        tablet:    { name: 'Tablet',   styles: { width: '768px', height: '1024px' } },
        laptop:    { name: 'Laptop',   styles: { width: '1024px', height: '768px' } },
        desktop:   { name: 'Desktop',  styles: { width: '1280px', height: '900px' } },
        wide:      { name: 'Wide',     styles: { width: '1536px', height: '1024px' } },
      },
      defaultViewport: 'desktop',
    },
    layout: 'centered',
    options: {
      storySort: {
        order: [
          'Design System',
          ['Introduction', 'Design Tokens', 'Foundations', ['Colors', 'Typography', 'Spacing'],
           'Atoms', 'Molecules', 'Organisms', 'Layout', 'Templates'],
        ],
      },
    },
  },
  globalTypes: {
    theme: {
      name: 'Theme',
      description: 'Toggle light/dark mode',
      defaultValue: 'light',
      toolbar: {
        icon: 'circlehollow',
        items: [
          { value: 'light', icon: 'sun', title: 'Light' },
          { value: 'dark',  icon: 'moon', title: 'Dark' },
        ],
        showName: true,
        dynamicTitle: true,
      },
    },
  },
  decorators: [
    (storyFn, context) => {
      const theme = context.globals['theme'] ?? 'light';
      document.documentElement.setAttribute('data-theme', theme);
      document.body.style.backgroundColor =
        theme === 'dark' ? '#0F172A' : '#FFFFFF';
      return storyFn();
    },
  ],
};
export default preview;
```

---

## Step 5 — Create `.storybook/theme.ts` (Custom Storybook UI Theme)

Read the brand primary color from the token file before generating:

```typescript
import { create } from '@storybook/theming/create';

export default create({
  base: 'light',

  // Brand
  brandTitle: '[DS Name] Design System',
  brandUrl: '/',
  brandImage: '/logo.svg',     // place logo in /public/logo.svg
  brandTarget: '_self',

  // Colors — update with actual DS brand colors
  colorPrimary:   '#3B82F6',  // --color-brand
  colorSecondary: '#1D4ED8',  // --color-brand-hover

  // UI chrome
  appBg:          '#F8FAFC',
  appContentBg:   '#FFFFFF',
  appPreviewBg:   '#FFFFFF',
  appBorderColor: '#E2E8F0',
  appBorderRadius: 6,

  // Text
  textColor:    '#0F172A',
  textMutedColor: '#64748B',
  textInverseColor: '#FFFFFF',

  // Toolbar
  barTextColor:     '#64748B',
  barHoverColor:    '#0F172A',
  barSelectedColor: '#3B82F6',
  barBg:            '#FFFFFF',

  // Input fields
  inputBg:           '#FFFFFF',
  inputBorder:       '#CBD5E1',
  inputTextColor:    '#0F172A',
  inputBorderRadius: 6,

  // Typography
  fontBase: '"Inter", system-ui, -apple-system, sans-serif',
  fontCode: '"JetBrains Mono", "Fira Code", monospace',
});
```

Register in `.storybook/manager.ts`:
```typescript
import { addons } from '@storybook/manager-api';
import customTheme from './theme';

addons.setConfig({ theme: customTheme });
```

---

## Step 6 — Create MDX documentation pages

### `stories/Introduction.mdx`

```mdx
import { Meta } from '@storybook/blocks';
<Meta title="Design System/Introduction" />

# Design System

A comprehensive component library for building consistent Angular applications.

## Getting started

```bash
npm install @[scope]/[ds-name]
```

Import the tokens in your `styles.scss`:
```scss
@use '@[scope]/[ds-name]/tokens' as *;
```

Import components as needed:
```typescript
import { DsButtonComponent } from '@[scope]/[ds-name]';
```

## Development workflow

| Terminal | Command | Purpose |
|----------|---------|---------|
| 1 | `npm run build:ds:watch` | Compile DS library |
| 2 | `npm run storybook` | Component catalog at :6006 |
| 3 | `npm run start` | Main app at :4200 |
```

### `stories/DesignTokens.mdx`

```mdx
import { Meta, ColorPalette, ColorItem, Typeset } from '@storybook/blocks';
<Meta title="Design System/Design Tokens" />

# Design Tokens

## Color Palette

<ColorPalette>
  <ColorItem title="Brand" subtitle="--color-brand-*" colors={{
    '50': 'var(--brand-50)', '500': 'var(--brand-500)', '900': 'var(--brand-900)'
  }} />
  <ColorItem title="Neutral" subtitle="--neutral-*" colors={{
    '50': 'var(--neutral-50)', '500': 'var(--neutral-500)', '950': 'var(--neutral-950)'
  }} />
  <ColorItem title="Semantic" subtitle="--color-*" colors={{
    'brand': 'var(--color-brand)',
    'error': 'var(--color-error)',
    'success': 'var(--color-success)',
    'warning': 'var(--color-warning)',
    'info': 'var(--color-info)',
  }} />
</ColorPalette>

## Typography

<Typeset
  fontSizes={['12px', '14px', '16px', '18px', '20px', '24px', '30px', '36px', '48px']}
  fontWeight={400}
  sampleText="The quick brown fox jumps over the lazy dog"
  fontFamily="var(--font-sans)"
/>
```

---

## Step 7 — Update package.json scripts

Ensure these scripts exist in the root `package.json`:

```json
{
  "storybook": "storybook dev -p 6006",
  "build:storybook": "storybook build -o dist/storybook"
}
```

---

## Step 8 — Validate

```bash
# Start Storybook and verify it loads
npm run storybook &
sleep 10
curl -s http://localhost:6006 | grep -q "storybook" && echo "✅ Storybook running" || echo "❌ Storybook failed"
kill %1

# Build static Storybook
npm run build:storybook && echo "✅ Storybook built successfully"
```

---

## Step 9 — Report

List every file created/modified, confirm the Storybook URL (`:6006`), and suggest next steps:
- Add Chromatic token with `/ds-publish` workflow
- Add story for each component with `/gen-component`
