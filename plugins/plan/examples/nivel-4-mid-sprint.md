# Nivel 4 — Mid-sprint: enriquecer o corregir en marcha

**Situación:** Ya estás en desarrollo. El equipo tiene tickets, pero algunos
están incompletos, una User Story cambió de scope, o apareció un bug/spike
inesperado. Necesitas usar el plugin de forma quirúrgica, no desde cero.

**Comandos a usar:** `/plan:project-manager` con comandos específicos,
o los agentes directamente.

---

## Ejemplo A — Enriquecer una User Story incompleta

El equipo te dice que US-006 ("Configurar preferencias de notificaciones")
está muy vaga para arrancar a desarrollar.

```
/plan:project-manager

mejorar historia

## US-006: Configurar preferencias de notificaciones

**Como** Developer
**Quiero** poder desactivar ciertos tipos de notificaciones
**Para** no ser interrumpido con eventos que no son relevantes para mí

### Criterios de Aceptación
- [ ] Puedo activar/desactivar cada tipo de notificación
- [ ] Los cambios se guardan
```

**Qué produce:**

```markdown
## [original]
(la historia tal como estaba)

## [enhanced]

**Como** Developer
**Quiero** configurar mis preferencias de notificación por tipo de evento
**Para** recibir solo alertas relevantes a mi flujo de trabajo sin ruido innecesario

### Criterios de Aceptación

**Happy Path:**
- [ ] Pantalla de preferencias accesible desde perfil de usuario
- [ ] Tipos configurables: task_assigned, deadline_changed, comment_added,
  status_changed, mention
- [ ] Toggle por tipo: ON/OFF independiente
- [ ] Opción adicional por tipo: push | in-app | ambos | ninguno
- [ ] Cambios persisten en BD inmediatamente (no requiere guardar manual)
- [ ] Feedback visual de confirmación al cambiar un toggle

**Casos borde:**
- [ ] Si desactiva push pero mantiene in-app, el badge sigue actualizándose
- [ ] Si desactiva todos los tipos, no se envían notificaciones pero el
  historial in-app sigue existiendo (solo no aparecen nuevas)
- [ ] Preferencias son por usuario, no globales del sistema

**Errores:**
- [ ] Si falla guardar, el toggle vuelve a su estado anterior
- [ ] Mensaje de error visible: "No pudimos guardar tu preferencia. Intenta de nuevo."

**Requisitos no funcionales:**
- [ ] Cambio guardado en < 500ms
- [ ] Sin reload de página al cambiar preferencia

### Campos del modelo

| Campo | Tipo | Descripción |
|-------|------|-------------|
| user_id | UUID FK | Propietario de las preferencias |
| notification_type | ENUM | task_assigned, deadline_changed, etc. |
| push_enabled | BOOLEAN | Default: true |
| in_app_enabled | BOOLEAN | Default: true |

### Endpoints

| Método | URL | Descripción |
|--------|-----|-------------|
| GET | /api/v1/users/me/notification-preferences | Obtener preferencias |
| PUT | /api/v1/users/me/notification-preferences | Actualizar todas |
| PATCH | /api/v1/users/me/notification-preferences/:type | Actualizar una |

### Archivos a modificar
- `src/modules/users/notification-preferences.repository.ts`
- `src/modules/users/notification-preferences.service.ts`
- `src/api/users/preferences.controller.ts`
- `src/frontend/components/settings/NotificationPreferences.tsx`
- `src/frontend/hooks/useNotificationPreferences.ts`
```

---

## Ejemplo B — Crear ticket de BUG urgente

```
/plan:tickets

Necesito un ticket de BUG urgente:

Las notificaciones push llegan duplicadas cuando el usuario tiene
la app abierta en dos pestañas al mismo tiempo. Afecta a todos los usuarios.
Stack: Node.js + Socket.io + Redis pub/sub.
```

**Qué produce:**

```markdown
## Ticket: NOTIF-BUG-001

**Título:** [BUG] Notificaciones push duplicadas con múltiples pestañas abiertas
**Tipo:** BUG
**Estimación:** 3h
**Prioridad:** Crítica
**Sprint:** Actual (hotfix)

### Descripción
Cuando un usuario tiene la aplicación abierta simultáneamente en más de una
pestaña del navegador, cada pestaña establece su propia conexión WebSocket.
Al publicar en Redis, el mensaje se emite a todas las conexiones activas del
usuario, resultando en N pushes por M pestañas abiertas.

### Root cause probable
El canal Redis `notifications:{user_id}` distribuye a todas las conexiones
del usuario sin deduplicar. Se necesita o bien un mecanismo de room único
por usuario (Socket.io rooms) o tracking de conexiones activas por user_id
para emitir una sola vez.

### Criterios de Aceptación
- [ ] Con 2 pestañas abiertas: llega exactamente 1 notificación push
- [ ] Con 5 pestañas abiertas: llega exactamente 1 notificación push
- [ ] Al cerrar todas las pestañas y reabrir: sigue llegando 1 notificación
- [ ] Test de regresión: con 1 pestaña sigue llegando 1 notificación

### Archivos a modificar
- `src/modules/websocket/websocket.gateway.ts` — lógica de rooms por usuario
- `src/modules/notifications/notification.service.ts` — emit deduplicado
- `tests/integration/websocket-dedup.test.ts` — test caso duplicado

### Tareas técnicas
1. [ ] Investigar Socket.io rooms: unir a cada usuario a room `user:{user_id}`
2. [ ] Cambiar emit de `socket.to(userId)` a `io.to(`user:{userId}`)`
3. [ ] Verificar que el join al room ocurre en handshake de auth
4. [ ] Test de integración con cliente simulado en 2 conexiones paralelas

### Dependencias
- **Bloqueado por:** Ninguno
- **Bloquea a:** NOTIF-004 (requiere fix antes del release)
```

---

## Ejemplo C — Crear SPIKE de investigación técnica

```
/plan:tickets

Necesito un spike para investigar si usamos WebSockets o Server-Sent Events
para las notificaciones. Tenemos dudas sobre la compatibilidad con nuestro
load balancer nginx y la necesidad de sticky sessions.
Equipo necesita la decisión para el lunes.
```

**Qué produce:**

```markdown
## Ticket: NOTIF-SPIKE-001

**Título:** [SPIKE] Evaluar WebSockets vs SSE para notificaciones en tiempo real
**Tipo:** SPIKE
**Estimación:** 3h
**Prioridad:** Alta
**Sprint:** Actual

### Descripción
Investigación técnica para decidir el protocolo de entrega de notificaciones
en tiempo real. El resultado es un documento de decisión (ADR), no código de producción.

### Preguntas a responder
1. ¿Nginx soporta WebSockets con balanceo de carga sin sticky sessions?
2. ¿SSE es suficiente para nuestro caso de uso (unidireccional servidor→cliente)?
3. ¿Qué pasa con reconexión automática en cada opción?
4. ¿Impacto en conexiones simultáneas (1000 usuarios activos)?

### Entregable esperado
Documento `docs/adr/0003-realtime-protocol.md` con:
- Comparativa WebSockets vs SSE vs Long Polling
- Recomendación fundamentada con pros/cons
- Decisión final y plan de implementación

### Criterios de aceptación del spike
- [ ] ADR redactado y en repositorio
- [ ] Prototipo mínimo de la opción elegida (no producción)
- [ ] Presentado al equipo antes del lunes

### Tareas
1. [ ] Revisar docs nginx WebSocket proxying
2. [ ] Probar SSE con nginx sin sticky sessions localmente
3. [ ] Benchmark básico de conexiones simultáneas
4. [ ] Redactar ADR con decisión
```

---

## Ejemplo D — Usar el agente Tech Lead directamente

En `/agents → tech-lead`:

```
Tengo un problema de arquitectura. Estamos usando polling desde el frontend
cada 5 segundos para actualizar el badge de notificaciones no leídas.
Con 500 usuarios activos eso son 6000 requests/minuto solo para el badge.

¿Cómo refactorizamos esto a WebSockets sin romper lo que ya funciona?
Necesito un plan de migración y los tickets correspondientes.
Stack: Node.js, React, nginx, PostgreSQL.
```

El agente Tech Lead analiza el problema, propone la arquitectura de migración,
dibuja el diagrama Mermaid del antes/después, y genera los tickets del plan de migración.

---

## Flujo recomendado en Nivel 4

```
Problema específico → comando quirúrgico o agente directo
No reiniciar el pipeline completo — entrar en el punto exacto que necesitas.
```
