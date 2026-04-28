# /plan:tickets

Genera **tickets técnicos de trabajo** a partir de una Épica o User Story. Cada ticket representa máximo 3 horas de esfuerzo.

## Contexto recibido

$ARGUMENTS

---

## Instrucciones

Actúa como **Tech Lead** senior. Si el usuario proporcionó la Épica o historia en `$ARGUMENTS`, úsala directamente. Si no, solicitar:

```
Para generar los tickets necesito:
1. La Épica o User Story a descomponer
2. El stack tecnológico (framework backend, frontend, ORM, etc.)
3. ¿Hay convenciones de naming en el proyecto para rutas/archivos?
```

**Regla de oro:** Si una tarea supera 3 horas → dividirla antes de crear el ticket.

---

## Proceso de generación de tickets

### Paso 1: Identificar unidades de trabajo

Para cada User Story o área de la Épica, identificar las capas afectadas:
- **Backend:** modelos, servicios, repositorios, endpoints, tests
- **Frontend:** componentes, páginas, estado, llamadas API, tests
- **Infra/Config:** variables de entorno, migraciones, CI/CD, documentación

### Paso 2: Generar cada ticket

```markdown
## Ticket: {PROJ-XXX}

**Título:** {[TIPO] Descripción concisa en lenguaje técnico}
**Tipo:** [FEATURE] | [BUG] | [TASK] | [SPIKE] | [IMPROVEMENT]
**Estimación:** {1h | 2h | 3h}
**Prioridad:** {Crítica | Alta | Media | Baja}
**Sprint:** {número o "Backlog"}
**Asignado a:** Sin asignar

---

### Descripción

{Contexto completo para que el desarrollador sea autónomo.
Incluir: qué existe actualmente, qué debe cambiar, por qué.}

### User Story relacionada
**Como** {persona} **quiero** {acción} **para** {beneficio}

---

### Criterios de Aceptación

- [ ] {Criterio técnico verificable 1}
- [ ] {Criterio técnico verificable 2}
- [ ] Tests unitarios/integración implementados
- [ ] Sin regresiones en funcionalidades existentes

---

### Especificación Técnica

#### Endpoints (si aplica)
| Método | URL | Request Body | Response | Auth |
|--------|-----|-------------|----------|------|
| POST | `/api/v1/{resource}` | `{campo: tipo}` | `201 {id, ...}` | Bearer |
| GET | `/api/v1/{resource}/:id` | — | `200 {objeto}` | Bearer |

#### Modelo / Schema (si aplica)
| Campo | Tipo | Requerido | Validación | Default |
|-------|------|-----------|------------|---------|
| id | UUID | Sí | Auto | — |
| {campo} | String | Sí | max: 255 | — |

#### Archivos a modificar
- `src/{capa}/{Archivo}.{ext}` — {descripción del cambio}
- `src/{capa}/{Archivo}.{ext}` — {descripción del cambio}
- `tests/{capa}/{Archivo}.test.{ext}` — {tests a agregar}

---

### Tareas técnicas

1. [ ] {Tarea de implementación 1}
2. [ ] {Tarea de implementación 2}
3. [ ] {Escribir tests unitarios}
4. [ ] {Actualizar documentación si aplica}

---

### Dependencias

- **Bloqueado por:** {PROJ-XXX o "Ninguno"}
- **Bloquea a:** {PROJ-YYY o "Ninguno"}

---

### Requisitos No Funcionales

- **Seguridad:** {validación de inputs, autorización, sanitización}
- **Performance:** {límites de tiempo de respuesta si aplica}
- **Accesibilidad:** {requisitos a11y si aplica}

---
```

### Paso 3: Escenario BDD (solo para tickets [FEATURE])

```gherkin
Feature: {nombre de la feature}
  Como {rol}
  Quiero {funcionalidad}
  Para {beneficio}

  Scenario: {flujo exitoso}
    Given {precondición}
    When {acción}
    Then {resultado}

  Scenario: {flujo de error}
    Given {precondición}
    When {acción inválida}
    Then {mensaje de error}
```

### Paso 4: Tabla resumen de todos los tickets generados

```markdown
## Resumen de Tickets

| ID | Título | Tipo | Estimación | Bloqueado por | Capa |
|----|--------|------|------------|---------------|------|
| T-001 | {título} | TASK | 2h | — | Backend |
| T-002 | {título} | FEATURE | 3h | T-001 | API |
| T-003 | {título} | FEATURE | 3h | T-001 | API |
| T-004 | {título} | FEATURE | 2h | T-002 | UI |
| T-005 | {título} | TASK | 3h | T-002, T-003 | Tests |

**Total:** N tickets · Xh de esfuerzo estimado
**Carga por sprint** (asumiendo 2 devs): ~Xh disponibles
```

---

## Reglas de calidad del ticket

Antes de entregar cada ticket, verificar:

- [ ] Título claro con tipo entre corchetes: `[FEATURE]`, `[TASK]`, etc.
- [ ] Estimación ≤ 3 horas (si es más, dividir)
- [ ] Criterios de aceptación verificables (sí/no)
- [ ] Archivos a modificar listados con rutas reales
- [ ] Dependencias identificadas explícitamente
- [ ] Contexto suficiente para autonomía del desarrollador
- [ ] BDD incluido para todos los tickets [FEATURE]

---

## Siguiente paso sugerido

Al finalizar, proponer:
> "Los tickets están listos. ¿Generamos el plan de pruebas completo con `/plan:project-manager` → `plan de pruebas`, o hay algo más que ajustar?"
