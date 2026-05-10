# Referencia: Testing con Jest

## Instalación

```bash
npm install --save-dev \
  jest \
  @jest/globals \
  jest-environment-jsdom \
  @angular-builders/jest \
  @types/jest \
  jest-preset-angular \
  ts-jest
```

---

## Configuración

### `jest.config.ts` — raíz del workspace

```typescript
import type { Config } from 'jest';

const config: Config = {
  projects: [
    '<rootDir>/projects/mi-design-system/jest.config.ts',
  ],
};

export default config;
```

### `jest.config.ts` — dentro de la librería

```typescript
import type { Config } from 'jest';

const config: Config = {
  displayName: 'mi-design-system',
  preset: 'jest-preset-angular',
  setupFilesAfterFramework: ['<rootDir>/setup-jest.ts'],
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.(ts|mjs|js|html)$': [
      'jest-preset-angular',
      {
        tsconfig: '<rootDir>/tsconfig.spec.json',
        stringifyContentPathRegex: '\\.(html|svg)$',
      },
    ],
  },
  transformIgnorePatterns: ['node_modules/(?!.*\\.mjs$)'],
  moduleNameMapper: {
    '^.+\\.(scss|sass|css)$': 'jest-preset-angular/build/FileMock.js',
  },
  collectCoverageFrom: [
    'src/lib/**/*.ts',
    '!src/lib/**/*.stories.ts',
    '!src/public-api.ts',
    '!src/lib/**/*.module.ts',
  ],
  coverageThresholds: {
    global: {
      statements: 80,
      branches:   70,
      functions:  80,
      lines:      80,
    },
  },
};

export default config;
```

### `setup-jest.ts`

```typescript
import 'jest-preset-angular/setup-jest';
```

### `tsconfig.spec.json`

```json
{
  "extends": "./tsconfig.lib.json",
  "compilerOptions": {
    "outDir": "../../out-tsc/spec",
    "module": "CommonJS",
    "types": ["jest"]
  },
  "include": [
    "setup-jest.ts",
    "src/**/*.spec.ts"
  ]
}
```

---

## Patrones de test por tipo

### Renderizado básico (todos los componentes)

```typescript
it('debe crearse correctamente', () => expect(component).toBeTruthy());

it('debe renderizar el elemento raíz', () => {
  const el = fixture.debugElement.query(By.css('.ds-{nombre}'));
  expect(el).not.toBeNull();
});
```

### Variantes con `it.each`

```typescript
it.each([
  ['primary',   'ds-btn--primary'],
  ['secondary', 'ds-btn--secondary'],
  ['ghost',     'ds-btn--ghost'],
  ['danger',    'ds-btn--danger'],
] as const)(
  'debe aplicar clase para variant="%s"',
  (variant, expectedClass) => {
    component.variant = variant;
    fixture.detectChanges();
    const el = fixture.debugElement.query(By.css('button'));
    expect(el.nativeElement.classList).toContain(expectedClass);
  }
);
```

### Eventos de usuario

```typescript
it('debe actualizar el valor al escribir', () => {
  const input: HTMLInputElement = fixture.debugElement.query(By.css('input')).nativeElement;
  input.value = 'test@email.com';
  input.dispatchEvent(new Event('input'));
  fixture.detectChanges();
  expect(component.value).toBe('test@email.com');
});
```

### ControlValueAccessor (componentes de formulario)

```typescript
it('debe implementar writeValue', () => {
  component.writeValue('valor');
  expect(component.value).toBe('valor');
});

it('debe manejar writeValue con null', () => {
  component.writeValue(null as any);
  expect(component.value).toBe('');
});

it('debe llamar onChange al escribir', () => {
  const spy = jest.fn();
  component.registerOnChange(spy);
  const input: HTMLInputElement = fixture.debugElement.query(By.css('input')).nativeElement;
  input.value = 'nuevo';
  input.dispatchEvent(new Event('input'));
  expect(spy).toHaveBeenCalledWith('nuevo');
});

it('debe desactivarse con setDisabledState(true)', () => {
  component.setDisabledState(true);
  fixture.detectChanges();
  const input: HTMLInputElement = fixture.debugElement.query(By.css('input')).nativeElement;
  expect(input.disabled).toBe(true);
});
```

### Accesibilidad

```typescript
it('debe agregar role="button" cuando clickable=true', () => {
  component.clickable = true;
  fixture.detectChanges();
  const el = fixture.debugElement.query(By.css('.ds-card'));
  expect(el.nativeElement.getAttribute('role')).toBe('button');
});

it('debe agregar aria-invalid cuando variant=error', () => {
  component.variant = 'error';
  fixture.detectChanges();
  const el = fixture.debugElement.query(By.css('input'));
  expect(el.nativeElement.getAttribute('aria-invalid')).toBe('true');
});

it('debe agregar aria-busy cuando loading=true', () => {
  component.loading = true;
  fixture.detectChanges();
  const el = fixture.debugElement.query(By.css('button'));
  expect(el.nativeElement.getAttribute('aria-busy')).toBe('true');
});
```

---

## Checklist de tests por componente

### ButtonComponent
- [ ] Se crea correctamente
- [ ] Renderiza `<button>`
- [ ] Clase de variante por defecto (primary)
- [ ] Todas las variantes con `it.each`
- [ ] Todos los tamaños con `it.each`
- [ ] `disabled=true` → `button.disabled === true`
- [ ] No dispara click cuando está deshabilitado
- [ ] `loading=true` → muestra spinner
- [ ] `loading=false` → no muestra spinner
- [ ] `loading=true` → `aria-busy`
- [ ] `loading=true` → botón deshabilitado
- [ ] `fullWidth=true` → clase `ds-btn--full`

### InputComponent
- [ ] Se crea correctamente
- [ ] Renderiza `<input>`
- [ ] Muestra label cuando se provee
- [ ] No muestra label cuando está vacío
- [ ] Muestra asterisco cuando `required=true`
- [ ] Todas las variantes con `it.each`
- [ ] Muestra `errorMsg` cuando `variant=error`
- [ ] No muestra error cuando `variant!=error`
- [ ] Mensaje de error con `role="alert"`
- [ ] Muestra hint cuando `variant!=error`
- [ ] Actualiza valor al escribir
- [ ] `isFocused=true` al hacer focus
- [ ] `isFocused=false` al hacer blur
- [ ] `writeValue` actualiza `value`
- [ ] `writeValue(null)` → `value = ''`
- [ ] `registerOnChange` llama callback al escribir
- [ ] `setDisabledState(true)` deshabilita el input
- [ ] `aria-invalid` cuando `variant=error`

### BadgeComponent
- [ ] Se crea correctamente
- [ ] Renderiza `<span>`
- [ ] Todas las variantes con `it.each`
- [ ] Todas las formas con `it.each`
- [ ] Todos los tamaños con `it.each`
- [ ] `dot=true` → muestra `.ds-badge__dot`
- [ ] `dot=false` → no muestra dot
- [ ] `outline=true` → clase `ds-badge--outline`
- [ ] `outline=false` → no tiene esa clase

### CardComponent
- [ ] Se crea correctamente
- [ ] Renderiza el contenedor
- [ ] Todas las variantes con `it.each`
- [ ] Todos los paddings con `it.each`
- [ ] `hoverable=true` → clase `ds-card--hoverable`
- [ ] `clickable=true` → `role="button"` y `tabindex="0"`
- [ ] `clickable=false` → no tiene `role`
- [ ] `fullHeight=true` → clase `ds-card--full-height`
- [ ] Slot body renderiza
- [ ] Slot header renderiza
- [ ] Slot footer renderiza

---

## Snapshot testing (opcional)

```bash
npm install --save-dev @storybook/addon-storyshots
```

```typescript
// src/storyshots.spec.ts
import initStoryshots from '@storybook/addon-storyshots';
initStoryshots({ storyKindRegex: /Design System/ });
```

Actualizar snapshots cuando sea intencional:
```bash
npm run test:ds -- --updateSnapshot
```
