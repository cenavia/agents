# Nivel 3 — Ya tengo User Stories priorizadas

**Situación:** Tienes el backlog ordenado con P1/P2/P3. Ahora necesitas
agrupar en épicas técnicas y arrancar la descomposición en tickets.
El equipo de desarrollo está esperando trabajo.

**Comando a usar:** `/plan:epic` y luego `/plan:tickets`

---

## Ejemplo A — Agrupar historias P1 en épicas

```
/plan:epic

Stack: Node.js + Express (backend), React + TypeScript (frontend),
PostgreSQL, Redis para caching. Equipo de 3 devs.

User Stories P1 del módulo de notificaciones:

US-001: Como Developer, quiero recibir push al asignar tarea
  - AC: entrega < 2s, muestra título/proyecto/asignador, abre tarea al tocar
  - Deps: ninguna

US-002: Como cualquier usuario, quiero ver un badge con el conteo de
  notificaciones no leídas en el ícono de campana
  - AC: se actualiza en tiempo real, desaparece al leer todas
  - Deps: US-001

US-003: Como cualquier usuario, quiero un centro de notificaciones con
  historial de los últimos 30 días ordenado por fecha
  - AC: carga paginada de 20 en 20, marca leído al abrir, filtrable
  - Deps: US-001
```

**Qué produce el Tech Lead:**

```markdown
# [EPIC] Sistema de Notificaciones en Tiempo Real

## Feature Overview

Infraestructura de notificaciones que conecta eventos del sistema
con los usuarios afectados a través de push notifications y una
bandeja in-app persistente...

## Technical Considerations

### Arquitectura
WebSockets (Socket.io) para entrega en tiempo real. Redis pub/sub
como broker de eventos. Service Worker para push en browser.

### Performance
- Entrega end-to-end < 2 segundos (P99)
- Redis cache para conteo de no leídas (evitar query en cada request)

## Diagrams

sequenceDiagram
  EventSystem->>Redis: Publish evento
  Redis->>NotificationService: Subscribe
  NotificationService->>DB: Persist notificación
  NotificationService->>WebSocket: Emit a usuario
  WebSocket->>Frontend: Actualizar badge + bandeja

## Suggested Tasks

| # | Título | Tipo | Estimación | Bloqueado por |
|---|--------|------|------------|---------------|
| 1 | [TASK] Config Redis pub/sub | TASK | 2h | — |
| 2 | [TASK] Schema DB notifications | TASK | 1h | — |
| 3 | [FEATURE] Service: crear notificación | FEATURE | 3h | 1, 2 |
| 4 | [FEATURE] WebSocket: emit a usuario | FEATURE | 3h | 1, 3 |
| 5 | [FEATURE] GET /notifications (paginado) | FEATURE | 2h | 2 |
| 6 | [FEATURE] PATCH /notifications/read | FEATURE | 1h | 5 |
| 7 | [FEATURE] UI: Badge contador | FEATURE | 2h | 4 |
| 8 | [FEATURE] UI: Centro de notificaciones | FEATURE | 3h | 5, 6 |
| 9 | [TASK] Tests de integración | TASK | 3h | 3, 4, 5 |

Total: 9 tickets · 20h estimadas
```

---

## Ejemplo B — Tickets directamente desde épica ya creada

```
/plan:tickets

Épica: [EPIC] Sistema de Notificaciones en Tiempo Real
Stack: Node.js + Express, React + TypeScript, PostgreSQL, Redis
Convención de archivos: src/modules/{feature}/{layer}.ts

Genera los tickets del Task 3 y 4 de la tabla de la épica:
- [FEATURE] Service: crear notificación
- [FEATURE] WebSocket: emit a usuario
```

**Qué produce:**

```markdown
## Ticket: NOTIF-003

**Título:** [FEATURE] Service: crear y persistir notificación
**Tipo:** FEATURE
**Estimación:** 3h
**Prioridad:** Alta
**Sprint:** 1

### Descripción
Implementar el servicio de dominio que recibe un evento del sistema
(tarea asignada, deadline cambiado, etc.), crea el registro de
notificación en PostgreSQL y publica en Redis para que el WebSocket
lo distribuya.

### User Story relacionada
**Como** Developer **quiero** recibir notificación al ser asignado
**para** no tener que revisar manualmente la plataforma

### Criterios de Aceptación
- [ ] Crea registro en tabla `notifications` con: user_id, type, payload, read_at null
- [ ] Publica en canal Redis `notifications:{user_id}` tras persistir
- [ ] Si falla Redis, el registro en DB queda y se reintenta en background
- [ ] Tests unitarios del servicio con mocks de DB y Redis
- [ ] Sin regresiones en módulo de tareas

### Especificación Técnica

#### Schema DB
| Campo | Tipo | Requerido | Default |
|-------|------|-----------|---------|
| id | UUID | Sí | gen_random_uuid() |
| user_id | UUID FK | Sí | — |
| type | ENUM | Sí | — |
| payload | JSONB | Sí | — |
| read_at | TIMESTAMP | No | NULL |
| created_at | TIMESTAMP | Sí | NOW() |

#### Archivos a modificar
- `src/modules/notifications/notification.service.ts` — crear servicio
- `src/modules/notifications/notification.repository.ts` — queries DB
- `src/modules/notifications/notification.types.ts` — tipos e interfaces
- `src/db/migrations/0042_create_notifications.sql` — migración
- `tests/modules/notifications/notification.service.test.ts` — tests

### Tareas técnicas
1. [ ] Crear migración de tabla `notifications`
2. [ ] Implementar `NotificationRepository.create()`
3. [ ] Implementar `NotificationService.emit(event, userId, payload)`
4. [ ] Publicar en Redis tras persistir
5. [ ] Manejo de error con retry en background
6. [ ] Tests unitarios con cobertura > 80%

### Dependencias
- **Bloqueado por:** NOTIF-001 (Redis config), NOTIF-002 (schema DB)
- **Bloquea a:** NOTIF-004 (WebSocket emit)

---

Feature: Crear y persistir notificación de sistema
  Como sistema
  Quiero persistir notificaciones y distribuirlas en tiempo real
  Para que los usuarios las reciban sin delay

  Scenario: Evento de tarea asignada
    Given el sistema emite evento task.assigned con user_id y task_id
    When el NotificationService procesa el evento
    Then existe registro en notifications con type="task_assigned"
    And se publica mensaje en Redis canal notifications:{user_id}

  Scenario: Fallo de Redis
    Given Redis no está disponible
    When el servicio intenta publicar
    Then el registro en DB se crea correctamente
    And se encola para reintento en background job
```

---

## Flujo recomendado en Nivel 3

```
/plan:epic    →  Épicas con arquitectura y tabla de tasks  (10 min por épica)
/plan:tickets →  Tickets técnicos detallados               (5 min por ticket)
```
