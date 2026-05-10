---
description: >
  Generate a single Angular Design System component with its full file set: TypeScript component,
  HTML template, SCSS styles, Jest tests, and Storybook stories. Use when building atoms (Button, Input,
  Select, Checkbox, Badge, Spinner, Icon, Tag), molecules (Card, Modal, Alert, Toast, Dropdown, Tabs,
  Accordion, Avatar), or organisms (Header, Sidebar, DataTable, Form). Also use to add a new custom
  component to an existing DS.
---

# Generate DS Component

Generate a complete, production-ready Angular DS component with stories and tests.

## Input

Component name and optional spec: $ARGUMENTS

Examples:
- `/gen-component button`
- `/gen-component card` with a hoverable variant and image slot
- `/gen-component data-table` with sorting, pagination, and row selection
- `/gen-component modal` with animated overlay and focus trap

---

## Step 1 — Read context

1. Read `skills/angular-design-system-storybook/SKILL.md` for component architecture rules.
2. Check the project structure:
   - Find `projects/*/src/lib/tokens/index.scss` to confirm tokens are available.
   - Check whether atoms/molecules/organisms directories exist and determine the tier.
   - Read `projects/*/src/public-api.ts` to see existing exports.
3. Determine the component tier from the component name:
   - Atom: Button, Input, Select, Checkbox, Radio, Toggle, Badge, Spinner, Icon, Tag, Divider
   - Molecule: Card, Modal, Alert, Toast, Dropdown, Tooltip, Tabs, Accordion, Avatar, SearchBar
   - Organism: Header, Sidebar, Footer, DataTable, Form, PageHero, NavigationBar, DashboardShell

---

## Step 2 — Plan the component

Before writing code, output a component spec table:

| Property | Value |
|----------|-------|
| Component name | `Ds[Name]Component` |
| Selector | `ds-[name]` |
| Tier | Atom / Molecule / Organism |
| Location | `projects/[ds]/src/lib/components/[tier]/[name]/` |
| Inputs | List all with types and defaults |
| Outputs | List any EventEmitters |
| Slots (ng-content) | List named slots if any |
| Form control | Yes (ControlValueAccessor) / No |
| ARIA role | ... |
| Stories | Default, AllVariants, AllSizes, States, [extras] |

Confirm with user if the spec looks correct before generating.

---

## Step 3 — Generate files

### `[name].component.ts`

```typescript
import {
  ChangeDetectionStrategy, Component, computed, input, output
} from '@angular/core';

export type [Name]Variant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type [Name]Size = 'sm' | 'md' | 'lg';

@Component({
  selector: 'ds-[name]',
  standalone: true,
  templateUrl: './[name].component.html',     // or inline template
  styleUrl: './[name].component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Ds[Name]Component {
  readonly variant = input<[Name]Variant>('primary');
  readonly size = input<[Name]Size>('md');
  readonly disabled = input<boolean>(false);
  // ... more inputs based on component spec

  readonly classes = computed(() => ({
    'ds-[name]': true,
    [`ds-[name]--${this.variant()}`]: true,
    [`ds-[name]--${this.size()}`]: true,
    'ds-[name]--disabled': this.disabled(),
  }));
}
```

For form components, implement `ControlValueAccessor`:
```typescript
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

providers: [{
  provide: NG_VALUE_ACCESSOR,
  useExisting: forwardRef(() => Ds[Name]Component),
  multi: true,
}]

// Implement: writeValue, registerOnChange, registerOnTouched, setDisabledState
```

### `[name].component.html`

Use semantic HTML with proper ARIA attributes:
- Buttons: `<button [attr.type]="type()" [disabled]="disabled()" [attr.aria-busy]="loading()">`
- Inputs: `<label [for]="id"> ... <input [id]="id" [attr.aria-invalid]="hasError()">`
- Decorative SVGs: `aria-hidden="true"`
- Interactive icons: `<button [attr.aria-label]="ariaLabel()">`

### `[name].component.scss`

```scss
:host {
  display: block; // or inline-block for inline elements
  box-sizing: border-box;
}

.ds-[name] {
  // base styles using only var(--token-name)
  font-family: var(--font-sans);
  transition: all var(--duration-fast) var(--ease-out);

  &:focus-visible {
    outline: none;
    box-shadow: var(--ring-brand);
  }

  // Variants
  &--primary { /* ... */ }
  &--secondary { /* ... */ }

  // Sizes
  &--sm { /* ... */ }
  &--md { /* ... */ }
  &--lg { /* ... */ }

  // States
  &--disabled {
    opacity: 0.5;
    cursor: not-allowed;
    pointer-events: none;
  }
}
```

### `[name].component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Ds[Name]Component } from './[name].component';

describe('Ds[Name]Component', () => {
  let fixture: ComponentFixture<Ds[Name]Component>;
  let component: Ds[Name]Component;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Ds[Name]Component],
    }).compileComponents();
    fixture = TestBed.createComponent(Ds[Name]Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('renders with default props', () => {
    expect(fixture.nativeElement).toBeTruthy();
  });

  it.each(['primary', 'secondary', 'ghost', 'danger'] as const)(
    'applies variant class: %s',
    (variant) => {
      fixture.componentRef.setInput('variant', variant);
      fixture.detectChanges();
      expect(fixture.nativeElement.querySelector('.ds-[name]')
        .classList.contains(`ds-[name]--${variant}`)).toBe(true);
    }
  );

  it('sets disabled state', () => {
    fixture.componentRef.setInput('disabled', true);
    fixture.detectChanges();
    const el = fixture.nativeElement.querySelector('[disabled], [aria-disabled="true"]');
    expect(el).toBeTruthy();
  });

  // ControlValueAccessor tests (if form component):
  it('implements writeValue', () => {
    component.writeValue('test-value');
    fixture.detectChanges();
    // assert internal state reflects value
  });
});
```

### `[name].stories.ts`

```typescript
import type { Meta, StoryObj } from '@storybook/angular';
import { Ds[Name]Component } from './[name].component';

const meta: Meta<Ds[Name]Component> = {
  title: 'Design System/[Atoms|Molecules|Organisms]/[Name]',
  component: Ds[Name]Component,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'ghost', 'danger'],
      description: 'Visual variant of the component',
      table: { defaultValue: { summary: 'primary' } },
    },
    // ... all other inputs
  },
};
export default meta;
type Story = StoryObj<Ds[Name]Component>;

export const Default: Story = {
  args: { variant: 'primary', size: 'md' },
};

export const AllVariants: Story = {
  render: () => ({
    template: `
      <div style="display:flex;gap:8px;flex-wrap:wrap;align-items:center">
        <ds-[name] variant="primary">Primary</ds-[name]>
        <ds-[name] variant="secondary">Secondary</ds-[name]>
        <ds-[name] variant="ghost">Ghost</ds-[name]>
        <ds-[name] variant="danger">Danger</ds-[name]>
      </div>
    `,
  }),
};

export const AllSizes: Story = {
  render: () => ({
    template: `
      <div style="display:flex;gap:8px;align-items:center">
        <ds-[name] size="sm">Small</ds-[name]>
        <ds-[name] size="md">Medium</ds-[name]>
        <ds-[name] size="lg">Large</ds-[name]>
      </div>
    `,
  }),
};

export const States: Story = {
  render: () => ({
    template: `
      <div style="display:flex;gap:8px;flex-wrap:wrap">
        <ds-[name]>Normal</ds-[name]>
        <ds-[name] [disabled]="true">Disabled</ds-[name]>
        <!-- Add loading, error, success states as applicable -->
      </div>
    `,
  }),
};
```

---

## Step 4 — Wire exports

Append to `projects/[ds-name]/src/public-api.ts`:
```typescript
export * from './lib/components/[tier]/[name]/[name].component';
```

---

## Step 5 — Validate

```bash
npx ng build [ds-name]    # must succeed
npx jest [name].component # must pass
```

---

## Step 6 — Report

List the 5 files created, the component selector, available inputs/variants, and the Storybook path.
