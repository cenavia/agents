---
name: angular-design-system
description: >
  Guía experta para construir, documentar, publicar y testear un Design System en Angular con Storybook.
  Cubre tres estrategias de integración (misma app, Angular Library en workspace, paquete npm privado),
  configuración de Design Tokens (colores, tipografía, espaciado, sombras), creación de componentes base
  reutilizables (Button, Input, Badge, Card), Storybook con autodocs, y suite de tests con Jest.

  Usa este skill SIEMPRE que el usuario mencione: "design system en Angular", "Storybook Angular",
  "Angular Library", "componentes reutilizables Angular", "tokens de diseño", "publicar librería Angular",
  "ng generate library", "jest Angular componentes", "stories Angular", "ds-button ds-input ds-badge ds-card",
  "ng-packagr", o cuando pida configurar un catálogo de componentes, documentar una UI kit en Angular,
  o integrar un sistema de diseño en uno o varios proyectos Angular.
---

# Angular Design System — Skill

Construye un Design System profesional en Angular con Storybook como catálogo visual, tokens CSS
como fuente de verdad visual, componentes standalone reutilizables y Jest para cobertura de tests.

## Decisión de estrategia

Antes de escribir código, determina qué estrategia usar basándote en el contexto del usuario:

| Señal del usuario | Estrategia |
|-------------------|------------|
| "Es solo para mi app" / proyecto pequeño | Estrategia 1 — misma app |
| "Varias apps en el mismo repo" / equipo mediano | **Estrategia 2 — Angular Library** ← recomendada |
| "Varios repositorios" / empresa grande / versionado independiente | Estrategia 3 — paquete npm |

Si hay duda, pregunta una sola vez: "¿el Design System será usado por más de una aplicación?"
- No → Estrategia 1
- Sí, mismo repo → Estrategia 2
- Sí, repos distintos → Estrategia 3

Lee el archivo de referencia correspondiente a la estrategia elegida antes de generar código.

---

## Archivos de referencia

| Archivo | Cuándo leerlo |
|---------|---------------|
| `references/strategy-2-workspace.md` | Estrategia 2: workspace + Angular Library |
| `references/strategy-3-npm.md`       | Estrategia 3: publicación npm privado + CI/CD |
| `references/jest-testing.md`         | Configuración Jest y tests por componente |

---

## Flujo de trabajo estándar

Sigue este orden para cualquier estrategia:

```
1. Crear workspace / proyecto
2. Configurar Design Tokens (SCSS custom properties)
3. Crear componentes base standalone
4. Configurar public-api.ts (exports)
5. Instalar y configurar Storybook
6. Escribir Stories por componente
7. Configurar Jest y escribir tests
8. (Estrategia 3) Publicar a npm y configurar CI/CD
```

---

## Reglas siempre activas

Estas reglas aplican a cualquier estrategia y deben seguirse en todo código generado:

### Tokens
- Los componentes NUNCA usan valores hardcodeados (colores hex, px, fuentes literales).
- Todo valor visual proviene de una CSS custom property (`var(--token-name)`).
- La jerarquía es: paleta base → aliases semánticos → consumo en componentes.
- Estructura de tokens: `_colors.scss`, `_typography.scss`, `_spacing.scss`, `_shadows.scss` + `index.scss`.

### Componentes
- Todos los componentes son **standalone** (`standalone: true`).
- Cada componente expone tipos TypeScript para sus `@Input()` (ej: `export type ButtonVariant`).
- Los `@Input()` siempre tienen valor por defecto.
- Accesibilidad: atributos `aria-*` correctos, `role` donde corresponda, `focus-visible` en estilos.
- Implementar `ControlValueAccessor` en todos los componentes de formulario (Input, Select, etc.).

### Storybook
- Título siguiendo la convención: `Design System/Components/Button`.
- Siempre incluir `tags: ['autodocs']` para documentación automática.
- Cada componente tiene mínimo 4 stories: Default, AllVariants, AllSizes y un caso de estado especial.
- Importar los tokens en `.storybook/preview.ts` para que los componentes rendericen correctamente.

### Tests (Jest)
- Un archivo `.spec.ts` por componente.
- Cobertura mínima recomendada: 80% statements, 70% branches, 80% functions.
- Usar `it.each` para testear todas las variantes en una sola declaración.
- No testear detalles de implementación CSS; testear presencia/ausencia de clases CSS.
- Todo componente de formulario debe testear la interfaz `ControlValueAccessor` completa.

---

## Estructura de archivos del Design System

```
projects/mi-design-system/src/lib/
├── tokens/
│   ├── _colors.scss       ← paleta base + aliases semánticos
│   ├── _typography.scss   ← fuentes, escala, pesos, interlineado
│   ├── _spacing.scss      ← espaciado + border-radius
│   ├── _shadows.scss      ← sombras + rings de foco
│   └── index.scss         ← @forward de todos los tokens
└── components/
    └── {nombre}/
        ├── {nombre}.component.ts
        ├── {nombre}.component.html   (si tiene template largo)
        ├── {nombre}.component.scss
        ├── {nombre}.component.spec.ts
        └── {nombre}.stories.ts
```

---

## Componentes base y sus características clave

### ButtonComponent (`ds-button`)
- Inputs: `variant` (primary|secondary|ghost|danger), `size` (sm|md|lg), `disabled`, `loading`, `fullWidth`
- Loading: muestra spinner CSS animado, aplica `disabled` y `aria-busy`
- Getter `classes()` computa clases BEM dinámicamente

### InputComponent (`ds-input`)
- Implementa `ControlValueAccessor` completo
- Inputs: `label`, `placeholder`, `hint`, `errorMsg`, `type`, `size`, `variant`, `disabled`, `readonly`, `required`
- Emite `aria-invalid` cuando `variant === 'error'`
- Mensaje de error con `role="alert"` para screen readers

### BadgeComponent (`ds-badge`)
- Inputs: `variant` (default|primary|success|warning|error|info), `size`, `shape` (pill|rounded|square), `dot`, `outline`
- `dot`: indicador de estado de 6px con `background: currentColor`
- `outline`: fondo transparente + borde del color de la variante

### CardComponent (`ds-card`)
- Inputs: `variant` (default|elevated|outlined|ghost), `padding`, `hoverable`, `clickable`, `fullHeight`
- Slots via `ng-content`: `[card-header]`, `[card-media]`, `[card-footer]`, body (default)
- `clickable`: agrega `role="button"` y `tabindex="0"`
- Slots vacíos se ocultan con `:empty { display: none }`

---

## Tokens de referencia rápida

### Colores semánticos (usar en componentes)
```scss
--color-brand            // azul principal
--color-brand-hover      // hover del brand
--color-bg-primary       // fondo blanco
--color-bg-secondary     // fondo gris muy claro
--color-text-primary     // texto oscuro principal
--color-text-muted       // texto secundario / placeholders
--color-border           // bordes sutiles
--color-error / --color-success / --color-warning / --color-info
```

### Espaciado
```scss
--space-1 (4px)  --space-2 (8px)   --space-3 (12px)
--space-4 (16px) --space-5 (20px)  --space-6 (24px)
--space-8 (32px) --space-10 (40px) --space-12 (48px)
```

### Tipografía
```scss
--text-xs / --text-sm / --text-base / --text-lg / --text-xl
--font-normal / --font-medium / --font-semibold / --font-bold
--font-sans / --font-mono
```

### Radios
```scss
--radius-sm / --radius-md / --radius-lg / --radius-xl / --radius-full
```

### Sombras
```scss
--shadow-sm / --shadow-md / --shadow-lg
--ring-brand / --ring-error / --ring-success   // para focus-visible
```

---

## Scripts npm estándar

```json
{
  "start":             "ng serve mi-app",
  "build:ds":          "ng build mi-design-system",
  "build:ds:watch":    "ng build mi-design-system --watch",
  "storybook":         "storybook dev -p 6006",
  "build:storybook":   "storybook build -o dist/storybook",
  "test":              "jest",
  "test:ds":           "jest --projects=projects/mi-design-system",
  "test:ds:watch":     "jest --projects=projects/mi-design-system --watch",
  "test:coverage":     "jest --coverage",
  "test:ci":           "jest --ci --coverage --runInBand"
}
```

---

## Checklist de calidad antes de entregar

Antes de dar por finalizado cualquier componente, verificar:

- [ ] No hay valores hardcodeados en SCSS (solo `var(--token)`)
- [ ] Todos los `@Input()` tienen tipo explícito y valor por defecto
- [ ] El componente tiene `aria-*` relevantes
- [ ] Hay una Story por cada variante principal
- [ ] Hay un `.spec.ts` con tests para variantes, estados y accesibilidad
- [ ] El componente está exportado en `public-api.ts`
- [ ] `tags: ['autodocs']` presente en la meta de la Story
