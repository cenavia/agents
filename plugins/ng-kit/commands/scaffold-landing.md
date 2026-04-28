# Scaffold Angular Landing Page

Create a complete, functional Angular project with a production-ready landing page from a single description.

## Project description

$ARGUMENTS

## Steps to follow

### Step 1 — Understand the project

Extract from the description:
- **Project name** (derive a kebab-case name if not explicit)
- **Industry / domain** (SaaS, e-commerce, portfolio, startup, etc.)
- **Key value proposition** (1 sentence)
- **Sections needed** (default: Hero, Features, How it works, Pricing, CTA, Footer)
- **Color palette preference** (default: infer from domain)

If the description is too vague to infer a name or value prop, ask one focused question before proceeding.

---

### Step 2 — Create the Angular project

1. Check Angular CLI availability:
   ```bash
   ng version 2>/dev/null || echo "not installed"
   ```

2. Create the project (use local CLI if available, otherwise npx):
   ```bash
   npx @angular/cli@latest new <project-name> \
     --style=scss \
     --routing=false \
     --ssr=false \
     --interactive=false \
     --ai-config=agent
   ```

3. Add Tailwind CSS:
   ```bash
   cd <project-name> && npx ng add tailwindcss --skip-confirmation
   ```

4. Install Google Fonts via `index.html` (Inter as default, or match the domain):
   Add to `<head>`:
   ```html
   <link rel="preconnect" href="https://fonts.googleapis.com">
   <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
   ```

---

### Step 3 — Scaffold the component structure

Generate each section as a standalone component using the CLI:

```bash
npx ng generate component landing/components/nav-bar --standalone --inline-template=false
npx ng generate component landing/components/hero-section --standalone --inline-template=false
npx ng generate component landing/components/features-section --standalone --inline-template=false
npx ng generate component landing/components/how-it-works --standalone --inline-template=false
npx ng generate component landing/components/pricing-section --standalone --inline-template=false
npx ng generate component landing/components/cta-section --standalone --inline-template=false
npx ng generate component landing/components/footer-section --standalone --inline-template=false
npx ng generate component landing/landing-page --standalone --inline-template=false
```

Use `inject()` for any services. No constructor injection.

---

### Step 4 — Wire `AppComponent`

Replace `app.component.ts` content:

```ts
import { Component } from '@angular/core';
import { LandingPageComponent } from './landing/landing-page/landing-page.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [LandingPageComponent],
  template: `<app-landing-page />`
})
export class AppComponent {}
```

---

### Step 5 — Implement each section

For each component, write full `.ts`, `.html`, and `.scss` files tailored to the project.

#### `LandingPageComponent`
Composes all sections in order:
```html
<app-nav-bar />
<main>
  <app-hero-section />
  <app-features-section />
  <app-how-it-works />
  <app-pricing-section />
  <app-cta-section />
</main>
<app-footer-section />
```

#### `NavBarComponent`
- Logo (text-based, use project name)
- Navigation links anchored to section IDs
- Primary CTA button (e.g. "Get started", "Try free")
- Mobile hamburger menu using a `signal<boolean>` for open state
- Sticky with backdrop blur: `sticky top-0 z-50 backdrop-blur-md bg-white/80`

#### `HeroSection`
- Headline (H1): bold, large, value proposition extracted from description
- Subheadline: 1-2 sentences expanding on the value prop
- Primary CTA button + secondary link ("See how it works")
- Hero visual: a styled `<div>` mockup or SVG illustration (no external images)
- Animated gradient background or subtle pattern

#### `FeaturesSection`
- Section title + subtitle
- 3–6 feature cards, each with:
  - SVG icon (inline, heroicons-style)
  - Feature name
  - 1-sentence description
- Grid layout: `grid grid-cols-1 md:grid-cols-3 gap-8`
- Features derived from the project description

#### `HowItWorksSection`
- Numbered steps (3 steps minimum)
- Each step: number badge + title + description
- Connected with a subtle divider line on desktop

#### `PricingSection`
- 3 tiers: Free / Pro / Enterprise (adapt names to domain)
- Highlight the middle tier with a colored border
- Feature list per tier with checkmarks
- CTA button per tier
- All pricing data as `signal()` arrays — no hardcoded template text

#### `CtaSection`
- Full-width colored band
- Short punchy headline
- Single large CTA button

#### `FooterSection`
- Logo + tagline
- Link columns (Product, Company, Legal)
- Social icons (SVG inline: Twitter/X, GitHub, LinkedIn)
- Copyright line with current year: `{{ currentYear() }}`
  ```ts
  currentYear = signal(new Date().getFullYear());
  ```

---

### Step 6 — Global styles

In `src/styles.scss`:
```scss
@import "tailwindcss";

:root {
  --primary: /* derive from domain, e.g. #6366f1 for SaaS */;
  --primary-dark: /* darker shade */;
}

html {
  scroll-behavior: smooth;
}

body {
  font-family: 'Inter', sans-serif;
  @apply text-gray-900 bg-white;
}

/* Section spacing utility */
.section {
  @apply py-20 px-4 max-w-6xl mx-auto;
}
```

---

### Step 7 — Build verification

```bash
npx ng build 2>&1
```

If there are errors, fix them before continuing. Do not skip this step.

---

### Step 8 — Start the dev server

```bash
npx ng serve --open
```

---

### Step 9 — Report

Output a summary with:
1. **Project structure** — file tree of what was created
2. **Sections built** — list with a one-line description of each
3. **How to run** — exact commands
4. **Suggested next steps** — e.g. replace placeholder copy, add real images, wire contact form, configure routing for multi-page

---

## Design principles to follow throughout

- **Mobile-first**: every section must look correct on 375px screens before desktop
- **No external image dependencies**: use inline SVGs, CSS gradients, or geometric shapes as visuals
- **Signals for all state**: `signal()` for any interactive state (menu open, selected plan, hover states via HostListener if needed)
- **Accessibility**: semantic HTML (`<nav>`, `<main>`, `<section>`, `<footer>`), ARIA labels on icon-only buttons, sufficient color contrast
- **Performance**: `ChangeDetectionStrategy.OnPush` on every component
