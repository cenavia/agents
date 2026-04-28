# Nivel 2 — Ya tengo el PRD

**Situación:** Tienes un PRD escrito (tuyo, del equipo, o generado en la Fase 2).
Quieres convertirlo en User Stories con criterios de aceptación claros, o
entrar directamente al backlog.

**Comando a usar:** `/plan:user-stories` y luego `/plan:backlog`

---

## Ejemplo A — PRD completo como entrada

```
/plan:user-stories

# PRD: Sistema de notificaciones en tiempo real

## Goal
**Problem:** Los usuarios de la plataforma no se enteran de cambios importantes
(nuevas tareas asignadas, comentarios, cambios de deadline) hasta que entran
manualmente a revisar. Esto causa retrasos y fricción en equipos distribuidos.

**Solution:** Sistema de notificaciones push + in-app que alerte en tiempo real
sobre eventos relevantes según el rol del usuario.

## User Personas
- **Project Manager (PM):** Necesita saber cuando alguien bloquea una tarea
- **Developer:** Necesita saber cuando le asignan trabajo nuevo o cambia una prioridad
- **Stakeholder:** Necesita ver actualizaciones de hitos, no el detalle operativo

## Functional Requirements
- RF-001: Notificación push al asignar tarea a un usuario
- RF-002: Notificación in-app con badge contador
- RF-003: Centro de notificaciones con historial de 30 días
- RF-004: Configuración de preferencias por tipo de notificación
- RF-005: Marcado como leído individual y masivo

## Non-Functional Requirements
- Performance: entrega de notificación < 2 segundos desde el evento
- Seguridad: notificaciones solo visibles para el destinatario
```

**Qué produce:**

El Business Analyst genera entre 8-12 User Stories como:

```markdown
## US-001: Recibir notificación al ser asignado a una tarea

**Como** Developer
**Quiero** recibir una notificación push inmediata cuando me asignen una tarea
**Para** poder planificar mi trabajo sin tener que revisar la plataforma constantemente

### Criterios de Aceptación

**Happy Path:**
- [ ] Al asignar tarea, el sistema envía push en < 2 segundos
- [ ] La notificación muestra: título de tarea, proyecto, asignador
- [ ] Al tocar la notificación, abre directamente la tarea

**Casos borde:**
- [ ] Si el usuario tiene notificaciones desactivadas, no se envía push
  pero sí se registra en el centro de notificaciones
- [ ] Si la tarea se reasigna antes de que el primero la lea, llega
  notificación de reasignación al nuevo asignado

**Errores:**
- [ ] Si el push falla, se reintenta máx. 3 veces en 60 segundos
- [ ] Si persiste el fallo, queda registrado en centro de notificaciones
```

---

## Ejemplo B — PRD en archivo existente

```
/plan:user-stories

El PRD está en /docs/ways-of-work/plan/notificaciones/prd.md
Genera las User Stories para las personas: PM, Developer y Stakeholder.
Asegúrate de cubrir los flujos de configuración de preferencias.
```

---

## Ejemplo C — Directo al backlog si ya tienes las User Stories

```
/plan:backlog

Tengo estas User Stories del módulo de notificaciones:

US-001: Notificación push al asignar tarea
US-002: Badge contador en ícono de campana
US-003: Centro de notificaciones con historial
US-004: Marcar como leído individual
US-005: Marcar todas como leídas
US-006: Configurar preferencias por tipo
US-007: Filtrar notificaciones por proyecto
US-008: Notificación de cambio de deadline
US-009: Digest diario de notificaciones por email

Stack del equipo: 2 frontend devs, 1 backend dev. Sprint de 2 semanas.
```

**Qué produce:**

```
| ID | User Story | Impacto | Urgencia | Complejidad | Score | Prioridad |
|----|-----------|---------|----------|-------------|-------|-----------|
| US-001 | Push al asignar | 5 | 5 | 2 | 17 | P1 |
| US-002 | Badge contador | 4 | 4 | 1 | 15 | P1 |
| US-003 | Centro historial | 5 | 4 | 3 | 15 | P1 |
| US-004 | Leer individual | 3 | 3 | 1 | 11 | P2 |
| US-005 | Leer todas | 2 | 2 | 1 | 7 | P2 |
| US-006 | Preferencias | 4 | 2 | 3 | 7 | P2 |
| US-007 | Filtrar | 2 | 1 | 2 | 3 | P3 |
| US-008 | Deadline alert | 4 | 3 | 2 | 13 | P2 |
| US-009 | Digest email | 3 | 1 | 3 | 4 | P3 |

Sprint 1 — P1: US-001, US-002, US-003 (~16h estimadas)
Sprint 2 — P2: US-004, US-005, US-008, US-006
Backlog — P3: US-007, US-009
```

---

## Flujo recomendado en Nivel 2

```
/plan:user-stories   →  N User Stories con AC  (15 min)
/plan:backlog        →  Backlog priorizado      (5 min)
/plan:epic           →  Épicas agrupadas        (10 min)
```
