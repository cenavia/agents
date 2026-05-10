# Referencia: Estrategia 2 — Angular Library en Workspace

## Cuándo usar esta estrategia
- Múltiples apps en el mismo repositorio
- Equipo mediano que comparte componentes
- Se quiere versionado implícito (sin publicar a npm)

---

## Comandos de setup

```bash
# 1. Crear workspace sin app inicial
ng new mi-workspace --no-create-application
cd mi-workspace

# 2. Crear la aplicación principal
ng generate application mi-app --style=scss --routing=true

# 3. Crear la Angular Library
ng generate library mi-design-system --prefix=ds

# 4. Eliminar archivos de ejemplo generados
rm projects/mi-design-system/src/lib/mi-design-system.component.ts
rm projects/mi-design-system/src/lib/mi-design-system.component.spec.ts
rm projects/mi-design-system/src/lib/mi-design-system.service.ts
rm projects/mi-design-system/src/lib/mi-design-system.service.spec.ts
rm projects/mi-design-system/src/lib/mi-design-system.module.ts

# 5. Crear estructura de carpetas
mkdir -p projects/mi-design-system/src/lib/tokens
mkdir -p projects/mi-design-system/src/lib/components/{button,input,badge,card}

# 6. Instalar Storybook
npx storybook@latest init
npm install --save-dev @storybook/addon-a11y @storybook/addon-themes
```

---

## `ng-package.json`

```json
{
  "$schema": "../../node_modules/ng-packagr/ng-package.schema.json",
  "lib": {
    "entryFile": "src/public-api.ts",
    "cssUrl": "inline"
  },
  "dest": "../../dist/mi-design-system"
}
```

> `"cssUrl": "inline"` incrusta los estilos dentro del bundle JS del componente.

---

## `public-api.ts`

```typescript
// projects/mi-design-system/src/public-api.ts

export * from './lib/components/button/button.component';
export * from './lib/components/input/input.component';
export * from './lib/components/badge/badge.component';
export * from './lib/components/card/card.component';

export type { ButtonVariant, ButtonSize }           from './lib/components/button/button.component';
export type { InputVariant, InputSize }             from './lib/components/input/input.component';
export type { BadgeVariant, BadgeSize, BadgeShape } from './lib/components/badge/badge.component';
export type { CardVariant, CardPadding }            from './lib/components/card/card.component';
```

---

## `.storybook/main.ts`

```typescript
import type { StorybookConfig } from '@storybook/angular';

const config: StorybookConfig = {
  stories: [
    '../projects/mi-design-system/src/**/*.mdx',
    '../projects/mi-design-system/src/**/*.stories.@(ts|mdx)',
  ],
  addons: [
    '@storybook/addon-essentials',
    '@storybook/addon-a11y',
    '@storybook/addon-themes',
    '@storybook/addon-interactions',
  ],
  framework: { name: '@storybook/angular', options: {} },
  angularBrowserTarget: 'mi-app:build',
  docs: { autodocs: 'tag' },
};

export default config;
```

---

## `.storybook/preview.ts`

```typescript
import type { Preview } from '@storybook/angular';
import '../projects/mi-design-system/src/lib/tokens/index.scss';

const preview: Preview = {
  parameters: {
    controls: { matchers: { color: /(background|color)$/i, date: /Date$/i } },
    backgrounds: {
      default: 'light',
      values: [
        { name: 'light', value: '#ffffff' },
        { name: 'gray',  value: '#f8fafc' },
        { name: 'dark',  value: '#0f172a' },
      ],
    },
    viewport: {
      viewports: {
        mobile:  { name: 'Mobile',  styles: { width: '375px',  height: '812px'  } },
        tablet:  { name: 'Tablet',  styles: { width: '768px',  height: '1024px' } },
        desktop: { name: 'Desktop', styles: { width: '1440px', height: '900px'  } },
      },
    },
  },
};

export default preview;
```

---

## `tsconfig.json` — paths (auto-generado por Angular CLI)

```json
{
  "compilerOptions": {
    "paths": {
      "mi-design-system": ["dist/mi-design-system"]
    }
  }
}
```

---

## `styles.scss` de la app consumidora

```scss
// projects/mi-app/src/styles.scss
@use '../../mi-design-system/src/lib/tokens/index';

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: var(--font-sans);
  font-size: var(--text-base);
  color: var(--color-text-primary);
  background: var(--color-bg-primary);
  -webkit-font-smoothing: antialiased;
}
```

---

## Consumo en un componente de la app

```typescript
import { ButtonComponent, CardComponent, BadgeComponent } from 'mi-design-system';

@Component({
  standalone: true,
  imports: [ButtonComponent, CardComponent, BadgeComponent],
  template: `
    <ds-card variant="elevated">
      <ds-badge variant="success" [dot]="true">Activo</ds-badge>
      <ds-button variant="primary">Guardar</ds-button>
    </ds-card>
  `,
})
export class MiComponente {}
```

---

## Terminales para desarrollo diario

```bash
# Terminal 1 — compila la librería en modo watch
npm run build:ds:watch

# Terminal 2 — Storybook (catálogo de componentes)
npm run storybook

# Terminal 3 — app que los consume
npm run start
```
