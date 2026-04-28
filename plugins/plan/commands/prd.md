# /plan:prd

Crea un **Product Requirements Document (PRD)** detallado para una feature, a partir de una Épica o del Artefacto #1 de ideación.

## Contexto recibido

$ARGUMENTS

---

## Instrucciones

Actúa como **Product Manager** experto en SaaS. Si el usuario proporcionó contexto en `$ARGUMENTS`, úsalo. Si no, solicitar:

```
Para crear el PRD necesito:
1. La Épica o Artefacto #1 de ideación (pega el documento o descríbelo)
2. El nombre de la feature específica a documentar
3. El equipo objetivo (si lo conoces): ingeniería, diseño, QA
```

---

## Output: PRD completo

Generar el PRD con esta estructura completa:

```markdown
# PRD: {Feature Name}

> **Epic:** {Nombre de la Épica}
> **Status:** Draft
> **Fecha:** {fecha actual}
> **Versión:** 1.0

---

## 1. Feature Name
{Nombre claro, conciso y descriptivo}

## 2. Epic
- **Epic:** {Nombre y descripción breve}
- **Artefacto #1:** {referencia al documento de ideación si existe}

## 3. Goal

### Problem
{3-5 oraciones describiendo el pain point actual del usuario}

### Solution
{Cómo esta feature resuelve el problema}

### Impact
| Métrica | Estado Actual | Objetivo |
|---------|--------------|---------|
| {métrica} | {valor actual} | {valor objetivo} |

## 4. User Personas
### {Nombre de Persona}
- **Rol:** {descripción}
- **Necesidades:** {lista}
- **Pain Points:** {lista}

## 5. User Stories
### US-001: {Título}
**Como** {persona} **quiero** {acción} **para** {beneficio}

## 6. Requirements

### 6.1 Functional Requirements
- **RF-001:** {requisito específico}

### 6.2 Non-Functional Requirements
- **Performance:** {requisito}
- **Security:** {requisito}
- **Accessibility:** {WCAG 2.1 AA si aplica}

## 7. Acceptance Criteria

### Para US-001
```gherkin
Scenario: {flujo exitoso}
  Given {precondición}
  When {acción}
  Then {resultado}
```

## 8. Out of Scope
- {Funcionalidad excluida 1}
- {Funcionalidad excluida 2}

## 9. Open Questions
| # | Pregunta | Owner | Estado |
|---|----------|-------|--------|
| 1 | {pregunta} | {nombre} | Open |
```

---

## Dónde guardar el PRD

Preguntar al usuario si desea guardarlo en `/docs/ways-of-work/plan/{epic-name}/{feature-name}/prd.md`. Si confirma, crear el archivo.

---

## Siguiente paso sugerido

Al finalizar, proponer:
> "El PRD está listo. El siguiente paso es generar las User Stories detalladas con `/plan:user-stories`. ¿Continuamos?"
