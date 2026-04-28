# Nivel 5 — Uso avanzado: agentes por rol

**Situación:** Conoces bien el pipeline. Quieres aprovechar los agentes
especializados directamente para sesiones de trabajo focalizadas,
o coordinar múltiples roles en una sesión de planificación de sprint.

---

## Ejemplo A — Sesión de planificación de sprint con 3 roles

Abres una sesión e invocas cada agente en secuencia para simular una
planning meeting:

### Paso 1 — Product Owner revisa el backlog de la semana

En `/agents → product-owner`:

```
El equipo tiene capacidad de 40h esta semana (2 devs × 20h).
El sprint anterior completamos US-001, US-002 y US-003.

Del backlog actual, prioriza cuáles historias entran al sprint:

US-004: Marcar notificación como leída (estimada: 3h)
US-005: Marcar todas como leídas (estimada: 2h)
US-006: Configurar preferencias por tipo (estimada: 8h → pendiente de dividir)
US-008: Alerta de cambio de deadline (estimada: 5h)
US-009: Digest diario por email (estimada: 12h)
NOTIF-BUG-001: Duplicados en múltiples pestañas (estimada: 3h, crítico)

Criterio de negocio: el bug crítico es P0 y no es negociable esta semana.
```

**Respuesta del PO:**
```
Sprint 8 — Capacidad: 40h

Entrada obligatoria:
✅ NOTIF-BUG-001: Fix duplicados (3h) — P0, no negociable

Entrada por impacto/urgencia:
✅ US-004: Marcar leída (3h) — P1, desbloquea US-005
✅ US-005: Marcar todas leídas (2h) — P1, depende de US-004
✅ US-008: Alerta deadline (5h) — P2, pedido explícito del cliente
✅ US-004+US-005 dejan 27h libres; US-008 usa 5h → quedan 22h

Recomendación:
⚠️ US-006 (8h) NO entra completa — pedir al Tech Lead que la divida
   antes de commitear. Podría caber la parte de backend (3h) si la divide.

Total comprometido: 13h fijas + US-006 parcial según división del TL.
```

### Paso 2 — Tech Lead divide US-006

En `/agents → tech-lead`:

```
El PO dice que US-006 (configurar preferencias de notificaciones) es demasiado
grande para este sprint completa. Tenemos 22h disponibles y queremos meter
al menos la parte de backend.

Stack: Node.js + Express, React + TypeScript, PostgreSQL.
Divide US-006 en tickets de máx 3h.
```

**Respuesta del TL:**
```
US-006 dividida en 5 tickets:

| ID | Título | Tipo | Estimación |
|----|--------|------|------------|
| PREF-001 | [TASK] Schema + migración notification_preferences | TASK | 1h |
| PREF-002 | [FEATURE] GET/PUT /notification-preferences | FEATURE | 3h |
| PREF-003 | [FEATURE] PATCH /notification-preferences/:type | FEATURE | 2h |
| PREF-004 | [FEATURE] UI: pantalla de preferencias | FEATURE | 3h |
| PREF-005 | [TASK] Tests integración preferencias | TASK | 2h |

Backend completo (PREF-001 + PREF-002 + PREF-003 + PREF-005): 8h
Frontend (PREF-004): 3h
Total: 11h

→ El sprint puede absorber backend completo + frontend si hay capacidad.
```

### Paso 3 — Business Analyst actualiza los criterios del ticket UI

En `/agents → business-analyst`:

```
El ticket PREF-004 (UI pantalla de preferencias) quedó sin criterios
de aceptación detallados. El desarrollador de frontend va a arrancar mañana.
Enriquece el ticket con AC completos y casos borde de UX.

Stack frontend: React + TypeScript + TailwindCSS.
```

---

## Ejemplo B — Planificación de un módulo nuevo completo

Comienzas con el agente PO para definir el scope, luego el BA para las historias,
luego el TL para la arquitectura. Todo en la misma sesión.

En `/agents → product-owner`:

```
Vamos a planificar el módulo de reportes de la plataforma.
El cliente quiere saber en todo momento el estado de sus proyectos,
tiempos invertidos y comparativa entre lo planificado y lo real.

Tengo el PRD aquí:

---
## Goal
Problem: Los PMs no tienen visibilidad del progreso real vs. estimado.
Actualizamos manualmente un Excel cada semana.

Solution: Dashboard de reportes con métricas calculadas automáticamente
desde los tickets cerrados: burn rate, velocity, % completado por épica.

Personas:
- PM: quiere ver el big picture de todos sus proyectos
- Stakeholder externo: quiere ver solo el % de avance del proyecto suyo
---

¿Qué User Personas necesitamos definir con más detalle?
¿Qué historias debería tener el MVP?
```

El PO refina las personas y propone el scope del MVP.

Luego en la misma sesión, invocas `/agents → business-analyst`:

```
Con este output del Product Owner, genera las User Stories del módulo de reportes.
El MVP solo cubre las historias P1.

[pegar output del PO]
```

Y finalmente `/agents → tech-lead`:

```
Con estas User Stories P1 de reportes, crea la épica técnica.
Stack: Node.js, PostgreSQL, React, Chart.js para visualizaciones.
El equipo necesita la arquitectura de cómo calculamos las métricas
sin afectar performance de la BD principal.

[pegar User Stories]
```

---

## Ejemplo C — Skill completo de project-manager para BDD

```
/plan:project-manager

crear bdd

## US-003: Centro de notificaciones con historial

**Como** Developer
**Quiero** ver todas mis notificaciones en un panel ordenado por fecha
**Para** no perder ningún evento aunque no estuviera conectado en ese momento

### Criterios de Aceptación
- [ ] Lista de notificaciones en orden cronológico inverso
- [ ] Paginación de 20 en 20
- [ ] Indicador visual de no leídas (fondo diferente)
- [ ] Historial de 30 días
- [ ] Notificaciones más antiguas se archivan automáticamente
```

**Qué produce el skill:**

```gherkin
Feature: Centro de notificaciones con historial
  Como Developer
  Quiero ver todas mis notificaciones en un panel ordenado por fecha
  Para no perder ningún evento aunque no estuviera conectado

  # --- Flujos principales ---

  Scenario: Ver notificaciones en orden cronológico
    Given el usuario tiene 5 notificaciones de los últimos 30 días
    When abre el centro de notificaciones
    Then ve las notificaciones ordenadas de más reciente a más antigua
    And cada notificación muestra tipo, descripción y tiempo relativo

  Scenario: Primera página de notificaciones
    Given el usuario tiene 45 notificaciones en total
    When abre el centro de notificaciones
    Then ve las 20 más recientes
    And hay un botón "Cargar más" visible

  Scenario: Cargar más notificaciones
    Given el usuario está en la primera página (20 notificaciones)
    When hace clic en "Cargar más"
    Then se agregan las siguientes 20 al final de la lista
    And si quedan 5, el botón "Cargar más" desaparece

  # --- Indicador visual ---

  Scenario: Notificación no leída con indicador visual
    Given el usuario tiene 3 notificaciones no leídas
    When abre el centro de notificaciones
    Then las 3 no leídas tienen fondo destacado (color diferente)
    And las leídas tienen fondo normal

  Scenario: Notificación se marca leída al abrirla
    Given hay una notificación no leída de tipo task_assigned
    When el usuario hace clic en esa notificación
    Then el fondo cambia al color de "leída"
    And el badge del ícono de campana disminuye en 1

  # --- Historial y archivo ---

  Scenario: Notificaciones dentro del período de retención
    Given hoy es 2026-04-27
    When el usuario abre el centro de notificaciones
    Then solo ve notificaciones con fecha >= 2026-03-28

  Scenario: Notificaciones archivadas no aparecen en la lista
    Given existen notificaciones con más de 30 días
    When el usuario abre el centro de notificaciones
    Then esas notificaciones no aparecen en la lista
    And no hay mensaje de error — simplemente no están

  # --- Sin notificaciones ---

  Scenario: Usuario sin notificaciones
    Given el usuario no tiene ninguna notificación en los últimos 30 días
    When abre el centro de notificaciones
    Then ve el estado vacío con mensaje "No tienes notificaciones recientes"
    And no hay botón "Cargar más"
```

---

## Resumen de cuándo usar cada nivel de acceso

| Situación | Punto de entrada |
|-----------|-----------------|
| Solo una idea | `/plan:pipeline` o `/plan:ideate` |
| Tengo un pitch | `/plan:ideate [texto del pitch]` |
| Tengo PRD | `/plan:user-stories [pegar PRD]` |
| Tengo User Stories | `/plan:backlog [listar historias]` |
| Backlog priorizado | `/plan:epic [historias P1]` |
| Tengo épica | `/plan:tickets [épica]` |
| Ticket incompleto | `/plan:project-manager` → `mejorar historia` |
| BUG urgente | `/plan:tickets [descripción del bug]` |
| Planning de sprint | Agentes: PO → BA → TL en secuencia |
| Decisión técnica | `/agents → tech-lead` directamente |
