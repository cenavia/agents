# React Dev Suite — Guías de flujo de trabajo

Este documento describe las secuencias de prompts para los dos escenarios principales de uso del plugin:

1. **Proyecto desde cero** — scaffold completo seguido de desarrollo por requerimientos
2. **Proyecto existente** — integración del plugin a un flujo ya establecido con arquitectura y funcionalidad previas

---

## Flujo 1 — Proyecto desde cero

### Fase 1: Creación del proyecto

El primer prompt configura todo: stack, estilos y arquitectura de carpetas. A partir de aquí, todos los comandos siguientes leen `.rds-context.json` y no vuelven a preguntar por la tecnología.

```
/react-dev-suite:new-project shop-app stack:modern styling:tailwind architecture:screaming
```

Si omites los argumentos, el comando presenta un menú interactivo:

```
/react-dev-suite:new-project shop-app
```

Resultado: directorio `shop-app/` con Vite + React 19 + TanStack Router + Zustand + RHF/Zod + Tailwind + Vitest configurados, carpetas base creadas y `.rds-context.json` escrito.

---

### Fase 2: Primer feature desde un requerimiento

Con el proyecto creado, cada historia de usuario se convierte en código real:

```
/react-dev-suite:from-story Como cliente quiero ver el catálogo de productos,
filtrarlos por categoría y precio, y agregar artículos al carrito.
```

El comando:
1. Lee el contexto del proyecto (stack + arquitectura)
2. Presenta el plan de implementación con la tabla de archivos
3. Espera confirmación antes de generar

Cuando confirmas, genera en orden: types → services → queries → store → components → tests.

---

### Fase 3: Segundo feature — flujo completo con confirmación

```
/react-dev-suite:from-story El administrador necesita gestionar usuarios registrados:
ver la lista completa, buscar por nombre o email, cambiar roles y desactivar cuentas.
```

El comando detecta automáticamente que `architecture: screaming` está en el contexto y genera en `src/features/users/` sin preguntar.

---

### Fase 4: Desarrollo incremental — comandos individuales

Cuando el requerimiento es más pequeño o ya tienes claro qué generar:

**Agregar un componente compartido:**
```
/react-dev-suite:new-component StatusBadge variant:fc style:tailwind
```

**Agregar un hook personalizado:**
```
/react-dev-suite:new-hook useCartSummary category:state
```

**Agregar un formulario:**
```
/react-dev-suite:new-form CheckoutForm fields:name:string,email:email,address:string,city:string,zip:string
```

**Agregar queries para un nuevo recurso:**
```
/react-dev-suite:new-query order api-base:/orders operations:list,get,create,update
```

**Agregar un store:**
```
/react-dev-suite:new-store cart fields:items:CartItem[],total:number with:persist,devtools
```

---

### Fase 5: Revisión y calidad

Antes de cada pull request o al final de una iteración:

**Revisión de un archivo específico:**
```
/react-dev-suite:review src/features/cart/components/CartList.tsx
```

**Auditoría de accesibilidad del proyecto:**
```
/react-dev-suite:audit a11y
```

**Auditoría de performance:**
```
/react-dev-suite:perf-audit
```

**Generar tests para un componente que quedó sin cobertura:**
```
/react-dev-suite:gen-tests src/features/orders/components/OrderList.tsx coverage:integration
```

---

### Ciclo completo — resumen

```
new-project           → proyecto base con contexto
    ↓
from-story            → feature completa desde un requerimiento
    ↓
new-component         → componentes adicionales según necesidad
new-hook              → hooks específicos
new-form              → formularios
new-query             → capa de datos
new-store             → estado
    ↓
review                → revisión de código antes del PR
gen-tests             → cobertura de tests
audit                 → auditoría de calidad (a11y, perf, security)
    ↓
from-story            → siguiente requerimiento (repite el ciclo)
```

---

---

## Flujo 2 — Integración a proyecto existente

Este flujo aplica cuando el proyecto ya existe, tiene arquitectura definida y funcionalidades creadas. El plugin **detecta** la estructura actual y se adapta a ella sin proponer cambios.

### Paso 1: Primera interacción — dejar que el plugin detecte el contexto

No se ejecuta `new-project`. El primer comando que uses ya detecta todo del filesystem y del `package.json`.

La forma más segura de empezar es con una auditoría de estado actual:

```
/react-dev-suite:audit all
```

Esto revela: qué stack está en uso, posibles anti-patrones, deuda técnica, y la arquitectura detectada. Sirve como línea base antes de agregar código nuevo.

---

### Paso 2: Verificar que la detección es correcta (opcional pero recomendado)

Antes de generar código, confirma que el plugin entiende bien el proyecto ejecutando un `from-story` pequeño y revisando el plan que presenta (sin confirmar la ejecución todavía):

```
/react-dev-suite:from-story Como usuario quiero ver una lista de notificaciones
con su estado leído/no leído.
```

El comando mostrará el plan con:
- El contexto detectado (stack + arquitectura)
- Los paths donde generaría los archivos
- La tabla de comandos que ejecutaría

Si los paths son incorrectos (ej. detectó `screaming` pero tu proyecto usa `file-type`), puedes corregirlo antes de confirmar.

---

### Paso 3: Desarrollo de nuevas funcionalidades sobre la base existente

Una vez verificado el contexto, el flujo es idéntico al de proyecto nuevo. El plugin genera en los paths correctos de tu arquitectura existente.

**Ejemplo — proyecto con arquitectura `file-type` (sin features/):**

```
/react-dev-suite:from-story El usuario puede ver y editar su perfil: nombre,
foto de avatar, bio y preferencias de notificación.
```

El plugin detecta `src/pages/` + `src/components/` → genera en:
- `src/pages/Profile/Profile.tsx`
- `src/pages/Profile/components/ProfileForm.tsx`
- `src/services/profileService.ts`
- `src/hooks/useProfile.ts`

**Ejemplo — proyecto con arquitectura `atomic`:**

```
/react-dev-suite:new-component ProductCard variant:fc
```

El plugin detecta `src/components/organisms/` → genera en `src/components/organisms/ProductCard/`.

---

### Paso 4: Agregar un feature a una arquitectura `modular` existente

```
/react-dev-suite:new-feature payments api-base:/payments with:form,router
```

El plugin detecta `src/features/*/views/` → genera en:
```
src/features/Payments/
├── views/PaymentsView.tsx
├── pages/PaymentsPage.tsx
├── components/
├── services/
└── index.ts
```

---

### Paso 5: Migración tecnológica sin cambiar la arquitectura

Si el proyecto usa Axios directo (sin TanStack Query) y quieres agregar queries para un nuevo recurso respetando ese patrón:

```
/react-dev-suite:new-query invoice api-base:/invoices operations:list,get,create
```

El plugin detecta `dataFetching: axios` (no `@tanstack/react-query` en package.json) y genera hooks `useState + useEffect` en lugar de `queryOptions` — sin sugerir migrar a TanStack Query.

---

### Paso 6: Auditoría focalizada antes de entregar

**Verificar que el nuevo código sigue la arquitectura existente:**
```
/react-dev-suite:audit architecture
```

Detecta: imports cross-feature, archivos fuera de lugar, `index.ts` faltantes.

**Revisar el código nuevo antes del PR:**
```
/react-dev-suite:review src/features/payments/
```

**Verificar preparación para una migración de React version:**
```
/react-dev-suite:audit react-19
```

---

### Ciclo de desarrollo continuo en proyecto existente

```
audit all             → línea base del estado actual (solo la primera vez)
    ↓
from-story            → nueva funcionalidad detectando arquitectura existente
    ↓
new-component         → componentes adicionales en los paths correctos
new-query             → datos adaptados al cliente HTTP existente
new-store             → estado adaptado a la lib de estado existente
new-form              → formularios adaptados al sistema de validación existente
    ↓
review                → revisión antes del PR
audit architecture    → verificar consistencia estructural
gen-tests             → cobertura faltante
    ↓
from-story            → siguiente requerimiento
```

---

---

## Referencia rápida de comandos por situación

| Situación | Comando |
|---|---|
| Inicio de proyecto nuevo | `/react-dev-suite:new-project` |
| Nueva funcionalidad desde un requerimiento | `/react-dev-suite:from-story` |
| Componente UI puntual | `/react-dev-suite:new-component` |
| Feature completa (sin requerimiento en texto) | `/react-dev-suite:new-feature` |
| Capa de datos para un recurso REST | `/react-dev-suite:new-query` |
| Store global o por feature | `/react-dev-suite:new-store` |
| Formulario con validación | `/react-dev-suite:new-form` |
| Hook personalizado | `/react-dev-suite:new-hook` |
| Tests para código existente | `/react-dev-suite:gen-tests` |
| Revisión de código para PR | `/react-dev-suite:review` |
| Auditoría de calidad | `/react-dev-suite:audit` |
| Auditoría de performance | `/react-dev-suite:perf-audit` |
| Migración de versión de React | `/react-dev-suite:migrate` |

---

## Notas sobre el comportamiento con proyectos existentes

- El plugin **nunca propone cambiar la arquitectura** detectada a menos que se lo indiques explícitamente.
- Si el proyecto no tiene `.rds-context.json`, el plugin detecta el stack y la arquitectura en cada comando leyendo `package.json` y el filesystem.
- Si la detección automática es incorrecta, puedes corregirla creando manualmente un `.rds-context.json` en la raíz del proyecto:

```json
{
  "projectName": "mi-proyecto",
  "stack": "classic",
  "routing": "react-router",
  "stateLib": "zustand",
  "dataFetching": "tanstack-query",
  "forms": "rhf-zod",
  "styling": "tailwind",
  "architecture": "file-type",
  "testing": "vitest-rtl",
  "srcDir": "src",
  "apiBaseUrl": "/api"
}
```

Este archivo es leído por todos los comandos del plugin y actúa como fuente de verdad para el resto del ciclo de desarrollo.
