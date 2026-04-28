---
name: breakdown-feature-prd
description: >
  Crea un Product Requirements Document (PRD) detallado para features nuevas basándose en una Épica.
  Usar cuando el usuario necesite:
  (1) Crear un PRD formal para una feature o enabler,
  (2) Documentar requisitos funcionales y no funcionales de una feature,
  (3) Definir criterios de aceptación claros para el equipo de ingeniería,
  (4) Delimitar el alcance (in scope / out of scope) de una feature,
  (5) Generar user stories a partir de un Epic.
  Requiere una Épica (Epic) existente como contexto. No usar para ideación inicial (usar /plan:product-ideation-brainstorm).
---

# Feature PRD

## Objetivo

Actuar como Product Manager experto en plataformas SaaS a gran escala. Tomar una feature o enabler de alto nivel de una Épica y crear un PRD detallado que sirva como fuente única de verdad para el equipo de ingeniería.

Si no hay suficiente información, hacer preguntas de clarificación antes de generar el PRD.

---

## Requisito Previo

**El Epic (Épica) es OBLIGATORIO.** Si el usuario no proporciona una Épica, solicitarla:

```
Por favor, proporciona la Épica (Epic) padre de esta feature para continuar.
Puedes incluir el título, descripción y enlace al documento de épica.
```

---

## Formato de Salida

El PRD se guarda en:
```
/docs/ways-of-work/plan/{epic-name}/{feature-name}/prd.md
```

Si la ruta no existe o el usuario no especifica una ubicación, preguntar dónde guardarlo o presentarlo directamente en el chat.

---

## Estructura del PRD

### 1. Feature Name

Nombre claro, conciso y descriptivo para la feature.

### 2. Epic

Enlace al PRD padre de la Épica y documentos de arquitectura relacionados.

### 3. Goal

- **Problem:** Describe el problema del usuario o necesidad de negocio (3-5 oraciones).
- **Solution:** Explica cómo esta feature resuelve el problema.
- **Impact:** Resultados esperados o métricas a mejorar (engagement, conversión, etc.).

### 4. User Personas

Describe el/los usuario(s) objetivo para esta feature.

### 5. User Stories

Formato: "As a `<user persona>`, I want to `<perform an action>` so that I can `<achieve a benefit>`."

Cubrir los caminos primarios y casos borde.

### 6. Requirements

- **Functional Requirements:** Lista detallada de lo que el sistema debe hacer. Ser específico e inequívoco.
- **Non-Functional Requirements:** Restricciones y atributos de calidad (performance, seguridad, accesibilidad, privacidad de datos).

### 7. Acceptance Criteria

Para cada user story o requisito principal, criterios de aceptación verificables.

Usar formato claro: checklist o Given/When/Then. Estos criterios se usan para validar que la feature esté completa.

### 8. Out of Scope

Listar explícitamente qué NO está incluido en esta feature para evitar scope creep.

---

## Plantilla Completa de PRD

```markdown
# PRD: {Feature Name}

> **Epic:** [{Epic Name}]({link-to-epic})
> **Status:** Draft | In Review | Approved
> **Fecha:** {YYYY-MM-DD}
> **Autor:** {nombre}
> **Versión:** 1.0

---

## 1. Feature Name

{Nombre claro y descriptivo}

---

## 2. Epic

- **Epic:** [{Nombre de la Épica}]({link})
- **Arquitectura:** [{Documento de arquitectura}]({link}) *(si existe)*

---

## 3. Goal

### Problem

{Descripción del problema del usuario o necesidad de negocio. 3-5 oraciones que expliquen el pain point actual.}

### Solution

{Cómo esta feature resuelve el problema. Descripción concisa de la solución propuesta.}

### Impact

| Métrica | Estado Actual | Objetivo |
|---------|--------------|---------|
| {Métrica 1} | {valor actual} | {valor objetivo} |
| {Métrica 2} | {valor actual} | {valor objetivo} |

---

## 4. User Personas

### Persona Principal: {Nombre}
- **Rol:** {descripción del rol}
- **Necesidades:** {lista de necesidades}
- **Pain Points:** {problemas actuales}

### Persona Secundaria: {Nombre} *(si aplica)*
- **Rol:** {descripción}
- **Necesidades:** {lista}

---

## 5. User Stories

### US-001: {Título}

**Como** {persona/rol}
**Quiero** {funcionalidad}
**Para** {beneficio/valor}

### US-002: {Título}

**Como** {persona/rol}
**Quiero** {funcionalidad}
**Para** {beneficio/valor}

---

## 6. Requirements

### 6.1 Functional Requirements

- **FR-001:** {Requisito funcional específico e inequívoco}
- **FR-002:** {Requisito funcional específico e inequívoco}
- **FR-003:** {Requisito funcional específico e inequívoco}

### 6.2 Non-Functional Requirements

- **Performance:** {requisitos de rendimiento}
- **Security:** {requisitos de seguridad}
- **Accessibility:** {requisitos de accesibilidad - WCAG 2.1}
- **Data Privacy:** {requisitos de privacidad de datos}
- **Scalability:** {requisitos de escalabilidad}

---

## 7. Acceptance Criteria

### Para US-001

- [ ] {Criterio verificable 1}
- [ ] {Criterio verificable 2}
- [ ] {Criterio verificable 3}

**O en formato Given/When/Then:**

```gherkin
Scenario: {escenario exitoso}
  Given {precondición}
  When {acción del usuario}
  Then {resultado esperado}

Scenario: {escenario de error}
  Given {precondición}
  When {acción incorrecta}
  Then {mensaje de error esperado}
```

### Para US-002

- [ ] {Criterio verificable 1}
- [ ] {Criterio verificable 2}

---

## 8. Out of Scope

Las siguientes funcionalidades **no** están incluidas en esta feature:

- {Funcionalidad excluida 1}
- {Funcionalidad excluida 2}
- {Funcionalidad excluida 3}

---

## 9. Open Questions

| # | Pregunta | Owner | Fecha límite | Estado |
|---|----------|-------|--------------|--------|
| 1 | {pregunta pendiente} | {nombre} | {fecha} | Open |

---

*PRD generado como parte del pipeline /plan. Siguiente paso: /plan:project-manager*
```

---

## Contexto del Pipeline

Este skill es el **Paso 2** del pipeline de planificación:

```
/plan:product-ideation-brainstorm → /plan:breakdown-feature-prd → /plan:project-manager
```

**Input esperado:** Epic o descripción de alto nivel de la feature.  
**Output:** PRD completo en Markdown, listo para ser consumido por `/plan:project-manager`.
