# Angular Design System Skill

Skill para construir, documentar, publicar y testear un Design System en Angular con Storybook.

---

## Contenido del skill

```
angular-design-system-skill/
├── SKILL.md                            ← reglas, flujo y tokens de referencia rápida
└── references/
    ├── strategy-2-workspace.md         ← Angular Library en workspace
    ├── strategy-3-npm.md               ← publicación como paquete npm privado
    └── jest-testing.md                 ← configuración Jest + patrones de tests
```

---

## Instalación

Copia la carpeta `angular-design-system-skill/` a tu directorio de skills de Claude:

```bash
# En Claude Code
cp -r angular-design-system-skill ~/.claude/skills/

# O empaqueta como .skill y súbela en Claude.ai → Settings → Skills
```

---

## Cómo activar cada estrategia

El skill detecta automáticamente la estrategia correcta según el contexto.
También puedes activarla explícitamente con cualquiera de estas frases:

---

### ▶ Estrategia 1 — Mismo proyecto (sin librería separada)

> Para proyectos pequeños donde el Design System vive dentro del `src/` de la misma app.

**Frases para activarla:**
```
"Crea un design system dentro de mi proyecto Angular existente"
"Quiero Storybook en mi app Angular sin librería separada"
"Agrega componentes reutilizables directamente en src/design-system"
```

**Qué genera:**
- Carpeta `src/design-system/tokens/` con los 4 archivos de tokens
- Carpeta `src/design-system/components/` con Button, Input, Badge, Card
- Configuración de `.storybook/` apuntando a `src/**/*.stories.ts`
- Importación de tokens en `styles.scss`

**Cuándo NO usarla:**
- Si planeas reutilizar los componentes en otra app
- Si el equipo tiene diseñadores que necesitan un catálogo independiente

---

### ▶ Estrategia 2 — Angular Library en workspace (recomendada)

> Para equipos medianos con múltiples apps en el mismo repositorio.
> La librería se compila a `dist/` y se importa como si fuera un paquete npm.

**Frases para activarla:**
```
"Crea un design system como Angular Library"
"Quiero una librería de componentes con ng generate library"
"Configura un workspace Angular con mi-app y mi-design-system"
"Cómo integrar el design system en mi app Angular desde una librería separada"
"Estrategia 2 del design system"
```

**Qué genera:**
- Workspace con `ng new --no-create-application`
- App principal con `ng generate application mi-app`
- Librería con `ng generate library mi-design-system --prefix=ds`
- Tokens en `projects/mi-design-system/src/lib/tokens/`
- Componentes en `projects/mi-design-system/src/lib/components/`
- `public-api.ts` con todos los exports
- `.storybook/main.ts` apuntando a la librería
- `tsconfig.json` con paths al `dist/`
- Scripts npm para los 3 terminales de desarrollo

**Referencia interna:** `references/strategy-2-workspace.md`

**Flujo de trabajo:**
```bash
# Terminal 1
npm run build:ds:watch   # compila la librería en tiempo real

# Terminal 2
npm run storybook        # catálogo de componentes en :6006

# Terminal 3
npm run start            # app en :4200
```

---

### ▶ Estrategia 3 — Paquete npm privado

> Para empresas con múltiples repositorios que necesitan versionar el Design System de forma independiente.

**Frases para activarla:**
```
"Quiero publicar mi design system en npm"
"Cómo publicar una Angular Library en GitHub Packages"
"Configura Verdaccio para mi librería de componentes"
"Quiero versionar el design system con SemVer"
"Estrategia 3 del design system"
"Configura el CI/CD para publicar mi librería Angular automáticamente"
"Cómo instalar el design system desde un registro privado"
```

**Qué genera:**
- `package.json` de la librería con scope `@mi-empresa/design-system`
- `ng-package.json` con `"cssUrl": "inline"`
- `.npmrc` para el registro privado elegido
- Instrucciones de autenticación (GitHub Packages o Verdaccio)
- Workflow de GitHub Actions para publicación automática en push a `main`
- Workflow de CI para validación en Pull Requests con cobertura en Codecov

**Referencia interna:** `references/strategy-3-npm.md`

**Opciones de registro:**

| Comando de activación | Registro generado |
|----------------------|-------------------|
| "usa GitHub Packages" | GitHub npm registry |
| "usa Verdaccio"       | Verdaccio con Docker |
| "usa npm privado"     | npm Org privada |
| "usa AWS"             | AWS CodeArtifact |

**Flujo de publicación:**
```bash
ng build mi-design-system        # compilar
npm version minor                # actualizar versión
cd dist/mi-design-system
npm publish                      # publicar al registro configurado
```

---

### ▶ Testing con Jest

> Aplica a cualquier estrategia. Se activa junto a cualquier solicitud de componentes o por separado.

**Frases para activarla:**
```
"Agrega tests Jest a los componentes del design system"
"Configura Jest en mi Angular Library"
"Escribe pruebas unitarias para Button, Input, Badge y Card"
"Cómo testear componentes Angular con Jest en lugar de Karma"
"Tests con cobertura para el design system"
```

**Qué genera:**
- `jest.config.ts` en raíz y en la librería
- `setup-jest.ts`
- `tsconfig.spec.json` actualizado
- `.spec.ts` completo para cada componente cubriendo:
  - Renderizado y clases CSS
  - Todas las variantes y tamaños con `it.each`
  - Eventos (input, focus, blur, click)
  - Accesibilidad (aria-*, roles, tabindex)
  - `ControlValueAccessor` completo (para InputComponent)
- Scripts en `package.json`: `test:ds`, `test:ds:watch`, `test:coverage`, `test:ci`

**Referencia interna:** `references/jest-testing.md`

---

## Combinaciones frecuentes

Puedes pedir varias cosas a la vez. El skill las combina automáticamente:

```
"Crea un design system con Angular Library, Storybook y tests Jest"
→ Estrategia 2 + Storybook + Jest completo

"Quiero publicar el design system en GitHub Packages con CI/CD y tests"
→ Estrategia 3 + GitHub Actions + Jest en CI

"Monta solo los tokens y el Button para empezar"
→ Estrategia 2 (parcial) + ButtonComponent + ButtonComponent.spec.ts
```

---

## Variables personalizables

Al activar cualquier estrategia, el skill usa estos valores por defecto.
Puedes especificar los tuyos en el prompt:

| Variable | Valor por defecto | Cómo cambiarlo |
|----------|------------------|----------------|
| Nombre del workspace | `mi-workspace` | "llama el workspace `acme-workspace`" |
| Nombre de la app | `mi-app` | "la app se llama `portal-clientes`" |
| Nombre de la librería | `mi-design-system` | "la librería se llama `ui-kit`" |
| Prefijo de componentes | `ds` | "usa el prefijo `acme`" |
| Scope npm | `@mi-empresa` | "el scope es `@acme-corp`" |
| Registro privado | GitHub Packages | "usa Verdaccio" / "usa npm org" |
| Color brand | `#3b82f6` (azul) | "el color principal es `#7c3aed`" |

---

## Preguntas frecuentes

**¿El skill genera el código completo o solo la estructura?**
Genera código completo y funcional: TypeScript, SCSS, HTML, stories y specs listos para usar.

**¿Puedo agregar más componentes después?**
Sí. El patrón es siempre: crear el componente → exportarlo en `public-api.ts` → escribir la story → escribir el spec.

**¿Los estilos del design system afectan a toda la app?**
Solo los tokens (CSS custom properties en `:root`) son globales. Los estilos de cada componente están encapsulados con Angular's ViewEncapsulation.

**¿Funciona con Angular Material o CDK?**
Sí. Los componentes del design system son standalone y pueden coexistir con Material. Los tokens CSS no colisionan con las variables de Material.

**¿Puedo usar el design system con Server-Side Rendering (SSR)?**
Sí, los componentes standalone son compatibles con SSR. Los tokens CSS son compatibles con cualquier entorno de renderizado.
