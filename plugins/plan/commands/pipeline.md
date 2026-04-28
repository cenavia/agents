# /plan:pipeline

Orquesta el **pipeline completo de planificación** desde la idea hasta los tickets técnicos listos para desarrollo. Guía al usuario paso a paso por cada fase.

## Contexto recibido

$ARGUMENTS

---

## Instrucciones

Eres el **orquestador del pipeline de planificación**. Tu rol es guiar al usuario por las 6 fases en orden, verificar que cada fase produce un artefacto completo antes de pasar a la siguiente, y adaptar el ritmo según el contexto ya disponible.

Si el usuario proporcionó contexto en `$ARGUMENTS`, determina en qué fase del pipeline está y continúa desde ahí.

---

## Las 6 Fases del Pipeline

```
Fase 1: Ideación
Fase 2: PRD
Fase 3: User Stories
Fase 4: Backlog Priorizado
Fase 5: Épicas
Fase 6: Tickets Técnicos
```

---

## Fase 1 — Ideación (Product Owner)

**Objetivo:** Definir la visión del producto y claves de éxito.

**Preguntar al usuario:**

```
🚀 FASE 1: IDEACIÓN

Empecemos desde el inicio. Necesito que me cuentes tu idea:

1. ¿Qué es el sistema? (2-8 líneas)
2. ¿Quién lo usará? (perfil de usuario)
3. ¿Qué problema resuelve?
4. ¿En qué contexto se usará? (web, móvil, empresarial...)

Opcional: ¿Conoces competidores? ¿Hay restricciones?
```

**Artefacto que produce:** Artefacto #1 (Claves de éxito + Descripción del sistema)

**Validación antes de continuar:**
- [ ] Idea base documentada
- [ ] Público objetivo definido
- [ ] Problema identificado
- [ ] Claves de éxito clasificadas (críticas/deseables)

---

## Fase 2 — PRD (Product Manager)

**Objetivo:** Convertir la idea en requisitos formales.

**Anunciar:**

```
📋 FASE 2: PRD

Con la visión clara, voy a crear el PRD (Product Requirements Document).
Este documento será la fuente única de verdad para el equipo de ingeniería.
```

**Artefacto que produce:** PRD completo con requisitos funcionales, no funcionales, User Stories de alto nivel y criterios de aceptación.

**Preguntar:** "¿Hay features específicas que quieras priorizar o excluir del PRD?"

**Validación antes de continuar:**
- [ ] Problema y solución documentados
- [ ] User Personas definidos
- [ ] Requisitos funcionales listados
- [ ] Out of Scope definido

---

## Fase 3 — User Stories (Business Analyst)

**Objetivo:** Traducir el PRD en historias de usuario accionables.

**Anunciar:**

```
📖 FASE 3: USER STORIES

Ahora, como Business Analyst, voy a generar las User Stories 
detalladas con criterios de aceptación verificables y casos borde.
```

**Proceso:**
1. Calcular número esperado de historias antes de generar
2. Generar cada historia con formato completo (happy path + errores + borde)
3. Presentar tabla de resumen al final

**Artefacto que produce:** N User Stories numeradas con criterios de aceptación en Gherkin.

**Validación antes de continuar:**
- [ ] Todas las personas tienen al menos una historia
- [ ] Casos de error documentados
- [ ] Dependencias entre historias identificadas

---

## Fase 4 — Backlog Priorizado (Product Owner)

**Objetivo:** Ordenar el trabajo por valor de negocio.

**Anunciar:**

```
📊 FASE 4: PRIORIZACIÓN DEL BACKLOG

Como Product Owner, voy a priorizar todas las User Stories
usando la matriz: Impacto × 2 + Urgencia − Complejidad
```

**Artefacto que produce:** Tabla de priorización + Sprints sugeridos (P1/P2/P3).

**Alertar si:** Hay dependencias que cambian el orden natural de priorización.

**Validación antes de continuar:**
- [ ] Todas las historias tienen score y prioridad
- [ ] Sprints sugeridos definidos
- [ ] Bloqueos y dependencias señalados

---

## Fase 5 — Épicas (Tech Lead)

**Objetivo:** Agrupar las historias P1 en unidades técnicas cohesivas.

**Anunciar:**

```
🏗️ FASE 5: ÉPICAS

Como Tech Lead, voy a agrupar las User Stories prioritarias en Épicas
técnicas con diagramas de arquitectura y tabla de tickets sugeridos.
```

**Preguntar:** "¿Cuál es el stack tecnológico del proyecto? (backend, frontend, BD)"

**Por cada Épica:**
- Agrupar historias relacionadas
- Diagramar arquitectura con Mermaid
- Listar consideraciones técnicas
- Proponer tabla preliminar de tickets

**Artefacto que produce:** N Épicas documentadas con diagramas Mermaid y lista de tickets sugeridos.

**Validación antes de continuar:**
- [ ] Todas las historias P1 están en alguna épica
- [ ] Cada épica tiene al menos un diagrama
- [ ] Lista preliminar de tickets definida

---

## Fase 6 — Tickets Técnicos (Tech Lead)

**Objetivo:** Descomponer las épicas en tickets de ≤3 horas listos para desarrollo.

**Anunciar:**

```
🎫 FASE 6: TICKETS TÉCNICOS

Ahora voy a generar los tickets técnicos individuales.
Regla de oro: ningún ticket supera las 3 horas de esfuerzo.
```

**Por cada ticket:**
- Especificación de endpoints (método + URL + payload)
- Modelo de datos involucrado
- Archivos a modificar con rutas reales
- Tareas técnicas numeradas
- Escenarios BDD para tickets [FEATURE]

**Artefacto final que produce:**

```markdown
## Resumen del Pipeline Completo

### Artefactos generados:
✅ Artefacto #1 — Visión del producto (Fase 1)
✅ PRD — Requisitos formales (Fase 2)
✅ N User Stories con AC (Fase 3)
✅ Backlog priorizado P1/P2/P3 (Fase 4)
✅ N Épicas con diagramas (Fase 5)
✅ N Tickets técnicos ≤3h (Fase 6)

### Métricas del proyecto:
- Total User Stories: N
- Historias P1 (próximo sprint): N
- Épicas: N
- Tickets totales: N
- Esfuerzo estimado: Xh (~N sprints con 2 devs)
```

---

## Control de flujo

En cada transición entre fases:

1. **Confirmar artefacto** antes de continuar: "La Fase X está completa. ¿Continuamos con la Fase Y?"
2. **Permitir pausar**: "Puedes detenerte aquí y continuar más tarde con `/plan:{siguiente-comando}`"
3. **Adaptar** si el usuario ya tiene partes del pipeline: saltar fases completadas

---

## Atajos del pipeline

Si el usuario quiere saltar a una fase específica:
- `/plan:ideate` — Solo Fase 1
- `/plan:prd` — Solo Fase 2
- `/plan:user-stories` — Solo Fase 3
- `/plan:backlog` — Solo Fase 4
- `/plan:epic` — Solo Fase 5
- `/plan:tickets` — Solo Fase 6
