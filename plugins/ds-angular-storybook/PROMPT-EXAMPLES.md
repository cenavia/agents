# Ejemplos de Prompts — ds-angular-storybook

Colección de prompts reales para cada flujo del plugin.
Carga el plugin antes de usar cualquier comando:

```bash
claude --plugin-dir /path/to/ds-angular-storybook
```

---

## Flujo 1 — DS completo desde un PRD

### 1a. PRD pegado directamente en el chat

```
/ds-angular-storybook:ds-from-prd

Producto: Finova — plataforma de gestión financiera para PYMEs.
Marca: Azul corporativo #0F4C81, acento verde #2ECC71, neutros slate.
Tipografía: Inter para UI, JetBrains Mono para datos y tablas.
Componentes requeridos: botones primarios/secundarios, inputs con validación,
tablas de datos con ordenación y paginación, tarjetas de KPI, modales de
confirmación, alertas de estado, sidebar de navegación colapsable.
Layouts: dashboard principal, página de onboarding, pantalla de login.
Modo oscuro: sí. Angular 18. Distribución: Angular Library en monorepo.
Accesibilidad: WCAG 2.1 AA.
```

---

### 1b. PRD desde archivo

```
/ds-angular-storybook:ds-from-prd ./docs/prd-ecommerce-v2.md
```

---

### 1c. Brief minimalista (el plugin pedirá lo que falte)

```
/ds-angular-storybook:ds-from-prd
Startup de salud digital. Colores: morado #7C3AED y blanco. Fuente: Nunito.
Necesito una app de dashboards médicos con gráficas y formularios.
```

---

## Flujo 2 — Solo tokens (brand refresh o proyecto existente)

### 2a. Desde paleta de marca

```
/ds-angular-storybook:gen-tokens
Color primario: #E11D48 (rojo coral)
Color secundario: #F97316 (naranja)
Neutros: zinc (fríos)
Fuente: Poppins (headings) + Inter (body)
Base: 16px
Modo oscuro: sí
Ruta: projects/my-ui-lib/src/lib/tokens/
```

---

### 2b. Actualizar solo la paleta de colores

```
/ds-angular-storybook:gen-tokens
Actualiza solo el archivo _colors.scss. Nuevo color brand: #6366F1 (indigo).
Mantén la misma estructura de aliases semánticos que ya existe en
projects/design-system/src/lib/tokens/_colors.scss
```

---

### 2c. Agregar soporte multi-marca

```
/ds-angular-storybook:gen-tokens
El DS ya tiene tokens base en projects/ui-kit/src/lib/tokens/.
Necesito agregar dos themes de marca:
- Marca A "Nexus": primario #0EA5E9, font: Roboto
- Marca B "Vertex": primario #10B981, font: DM Sans
Genera archivos de override por marca que solo redefinan los tokens semánticos.
```

---

## Flujo 3 — Generar componentes individuales

### 3a. Átomo simple

```
/ds-angular-storybook:gen-component button
```

---

### 3b. Átomo con spec detallada

```
/ds-angular-storybook:gen-component
Nombre: ds-badge
Variantes: default, primary, success, warning, error, info
Tamaños: sm, md, lg
Formas: pill, rounded, square
Props extra: dot (indicador de 6px), outline (fondo transparente + borde)
Storybook: incluir historia "WithDot" y "Outline" además de las estándar
```

---

### 3c. Molécula con slots

```
/ds-angular-storybook:gen-component card
Variantes: default, elevated, outlined, ghost
Padding: sm (16px), md (24px), lg (32px)
Props: hoverable, clickable, fullHeight
Slots via ng-content: [card-header], [card-media], [card-footer], body default
Cuando clickable=true: agregar role="button" y tabindex="0"
```

---

### 3d. Componente de formulario con ControlValueAccessor

```
/ds-angular-storybook:gen-component
Nombre: ds-select
Label, placeholder, hint, errorMsg
Opciones: array de {value, label, disabled}
Modo múltiple: prop "multiple"
Implementar ControlValueAccessor completo
Variantes de estado: default, error, success, disabled
ARIA: aria-invalid cuando variant=error, aria-describedby al hint/error
```

---

### 3e. Organismo complejo

```
/ds-angular-storybook:gen-component data-table
Columnas configurables: [{key, label, sortable, width}]
Ordenación: client-side con signal de sortState
Paginación: pageSize (10/25/50/100), currentPage, totalItems como inputs
Selección de filas: checkbox en cada fila + checkbox "seleccionar todo"
Loading state: skeleton rows mientras carga
Empty state: slot [empty-state] para contenido personalizado
Accesibilidad: role="grid", aria-sort en columnas, aria-label en checkboxes
```

---

## Flujo 4 — Sistema de layout

### 4a. Todos los primitivos de layout

```
/ds-angular-storybook:gen-layout
Genera el sistema de layout completo:
- ds-container (sizes: sm, md, lg, xl, 2xl, fluid)
- ds-stack (gap via tokens, align, dividers opcionales)
- ds-cluster (justify, align, wrap)
- ds-grid (cols fijos o auto-fit con minColWidth)
- ds-sidebar-layout (ancho sidebar configurable, colapsa en mobile)
- ds-split (ratios 1:1, 1:2, 2:1, 1:3)
Ubicación: projects/my-ds/src/lib/layout/
```

---

### 4b. Solo page templates

```
/ds-angular-storybook:gen-layout dashboard
Template de dashboard con:
- Sidebar izquierdo fijo 260px, colapsable a 64px (solo íconos) en tablet
- Header superior fijo 64px con búsqueda y avatar de usuario
- Área de contenido con scroll independiente
- Grid de 3 columnas para KPI cards, responsive a 1 columna en mobile
Usar los primitivos ds-sidebar-layout y ds-grid del DS existente
```

---

### 4c. Template de landing marketing

```
/ds-angular-storybook:gen-layout landing
Secciones: Hero (full-bleed bg + ds-container interno), Features (grid 3 cols
auto-fit min 280px), Testimonials (carousel placeholder), CTA (full-bleed brand
color), Footer (4 columnas → 2 en tablet → 1 en mobile).
Usar fluid() para font-size del hero title entre 2rem (mobile) y 4rem (desktop).
```

---

## Flujo 5 — Configurar Storybook

### 5a. Setup completo desde cero

```
/ds-angular-storybook:storybook-setup
Proyecto: projects/finova-ds/
Nombre del DS: Finova Design System
Color brand: #0F4C81
Logo: public/finova-logo.svg
Addons requeridos: a11y, interactions, designs, themes, chromatic
Dark mode toggle en toolbar: sí
Viewports: mobile (375), tablet (768), desktop (1280), wide (1536)
Orden de stories: Introduction → Tokens → Atoms → Molecules → Organisms → Layout
```

---

### 5b. Solo agregar el tema personalizado

```
/ds-angular-storybook:storybook-setup theme
DS Name: "Vertex UI"
Primary: #10B981
Fuente: DM Sans
Actualiza .storybook/theme.ts y .storybook/manager.ts solamente
```

---

### 5c. Solo crear páginas MDX de documentación

```
/ds-angular-storybook:storybook-setup docs
Crea las páginas MDX:
1. Introduction.mdx — bienvenida, instalación, workflow de 3 terminales
2. DesignTokens.mdx — paleta visual con ColorPalette blocks, escala tipográfica
3. Contributing.mdx — guía para agregar nuevos componentes al DS
4. Changelog.mdx — últimas versiones del DS
```

---

## Flujo 6 — Auditoría del DS

### 6a. Auditoría completa

```
/ds-angular-storybook:ds-audit
```

---

### 6b. Solo tokens hardcodeados

```
/ds-angular-storybook:ds-audit tokens
Busca valores hardcodeados en los SCSS de componentes.
Prioriza los críticos (colores hex directos) sobre los warnings (px en borders).
```

---

### 6c. Auditoría de accesibilidad antes de release

```
/ds-angular-storybook:ds-audit accessibility
Revisa todos los componentes en projects/my-ds/src/lib/components/
contra WCAG 2.1 AA. Enfócate en:
- Contraste de colores (marca los que requieren revisión manual en Lighthouse)
- ARIA roles faltantes
- Elementos interactivos sin label accesible
- Focus-visible ausente
Genera lista priorizada lista para el equipo de QA.
```

---

### 6d. Cobertura de Storybook antes de publicar

```
/ds-angular-storybook:ds-audit stories
Lista qué componentes no tienen stories, cuáles les falta la historia "States"
o "AllVariants", y cuáles no tienen el tag autodocs.
```

---

## Flujo 7 — Publicar el DS

### 7a. Bump patch y publicar a npm público

```
/ds-angular-storybook:ds-publish patch
Registry: npm público
Scope: @mi-empresa
Incluir CHANGELOG entry con: corrección de focus-visible en ds-input y ds-select
```

---

### 7b. Release minor a GitHub Packages

```
/ds-angular-storybook:ds-publish minor
Registry: https://npm.pkg.github.com
Scope: @mi-org
Nuevos componentes en esta versión: ds-accordion, ds-avatar, ds-tooltip
Dry run primero para verificar qué se incluye en el bundle.
```

---

### 7c. Preparar pipeline CI/CD sin publicar ahora

```
/ds-angular-storybook:ds-publish
Solo genera el archivo .github/workflows/publish-ds.yml para GitHub Actions.
Registry: npm privado en GitHub Packages.
Que incluya: build → test → publish al crear un tag ds-v*.
También el workflow de Chromatic en cada push a main.
No publicar todavía.
```

---

## Flujos combinados (conversacionales)

### Flujo A — DS desde cero en una sesión

```
# Paso 1: arquitectura
Actúa como design-system-architect. Tengo este PRD: [pegar PRD].
Dame el plan de arquitectura completo antes de generar código.

# Paso 2: tokens (tras aprobar el plan)
/ds-angular-storybook:gen-tokens
[brand info del PRD]

# Paso 3: componentes en orden de prioridad
/ds-angular-storybook:gen-component button
/ds-angular-storybook:gen-component input
/ds-angular-storybook:gen-component badge
/ds-angular-storybook:gen-component card

# Paso 4: layout
/ds-angular-storybook:gen-layout

# Paso 5: Storybook
/ds-angular-storybook:storybook-setup

# Paso 6: auditoría final
/ds-angular-storybook:ds-audit
```

---

### Flujo B — Incorporar DS a un proyecto Angular existente

```
Tengo un proyecto Angular 18 en ./my-app.
Quiero agregar un Design System sin crear un workspace nuevo (Estrategia 1).
Colores: #6D28D9 purple, neutros zinc. Fuente: Inter.
Solo necesito por ahora: ds-button, ds-input, ds-card y ds-badge.
¿Puedes configurar los tokens en src/design-system/tokens/ y los
componentes en src/design-system/components/?
```

---

### Flujo C — Migrar diseño de Figma al DS

```
Actúa como token-engineer.
Tengo estos valores exportados de Figma:

Colors: Primary/500 #3B82F6, Primary/700 #1D4ED8, Gray/50 #F9FAFB ... [lista]
Typography: Heading/XL size:36 weight:700 leading:1.2, Body/Base size:16 weight:400...
Spacing: 4, 8, 12, 16, 24, 32, 48, 64, 96px
Shadows: sm: 0 1px 3px rgba(0,0,0,0.1), md: 0 4px 6px...

Genera los 7 archivos de tokens SCSS en projects/ui-kit/src/lib/tokens/
respetando exactamente estos valores. Agrega dark mode con valores que tú
deduzcas como apropiados para cada token semántico.
```

---

### Flujo D — Renovar solo la capa visual (tokens) sin tocar componentes

```
/ds-angular-storybook:gen-tokens
Nuestro DS ya tiene componentes funcionando. Solo queremos un rebrand:
- Cambiar el color brand de #0EA5E9 (sky) a #8B5CF6 (violet)
- Cambiar la fuente de Roboto a Inter
- Ajustar los radios: todo más redondeado (radius-md: 8px → 12px)
Modifica SOLO _colors.scss, _typography.scss y la parte de radios en _spacing.scss.
No toques los archivos de componentes.
```
