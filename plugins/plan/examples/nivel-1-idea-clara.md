# Nivel 1 — Idea clara, sin documentación

**Situación:** Sabes qué quieres construir, conoces tu usuario objetivo y el
problema que resuelves. Quizás tienes un pitch de 3-5 líneas. No tienes nada
escrito formalmente todavía.

**Comando a usar:** `/plan:ideate` para el Artefacto #1, luego `/plan:prd`

---

## Ejemplo A — Pitch corto como entrada

```
/plan:ideate

Quiero construir una plataforma web para que consultores independientes
gestionen sus proyectos con clientes: contratos, hitos, pagos y reportes
de avance. El problema es que hoy usan Google Sheets o Notion y nada
está integrado. Mi público son consultores tech freelance, 25-40 años,
que trabajan con 3-8 clientes simultáneos.
```

**Qué produce el plugin:**

1. Te pregunta si quieres investigación de mercado (competidores, tendencias)
2. Genera tabla de claves de éxito clasificadas:

```
| # | Categoría | Clave de Éxito | Clasificación |
|---|-----------|----------------|---------------|
| 1 | Funcionalidad | Gestión unificada contrato→pago | Crítica |
| 2 | UX | Dashboard de estado por cliente | Crítica |
| 3 | Integraciones | Conexión con Stripe / PayPal | Crítica |
| 4 | Datos | Reportes de rentabilidad por proyecto | Deseable |
| 5 | Go-to-Market | Plan freemium para consultores nuevos | Deseable |
```

3. Genera el Artefacto #1 completo en Markdown

---

## Ejemplo B — Con investigación de mercado activada

```
/plan:ideate

Sistema de gestión de reservas para pequeños hoteles boutique.
El dueño del hotel hoy gestiona reservas por teléfono y WhatsApp,
pierde reservas, no tiene vista de disponibilidad en tiempo real
y no puede cobrar anticipos fácilmente.

Competidores que conozco: Booking.com, Airbnb, pero son para turistas,
no para el hotelero que quiere gestionar su propio establecimiento.

¿Puedes investigar qué más hay en el mercado?
```

**Qué hace el plugin:**
- Confirma que buscará en internet (ya autorizaste)
- Busca: "hotel management software boutique competitors 2024"
- Produce tabla de competidores con fortalezas/debilidades/oportunidades
- Genera Artefacto #1 con sección 2 de Análisis de Mercado incluida

---

## Ejemplo C — Saltar directo al PRD si ya tienes el Artefacto #1

Si ya tienes el Artefacto #1 de una sesión anterior:

```
/plan:prd

Epic: Plataforma de gestión para consultores freelance

Feature: Gestión de contratos con firmas digitales

Tenemos el Artefacto #1 del sistema. Esta feature específica cubre
el flujo de crear, enviar y firmar contratos con clientes directamente
desde la plataforma, sin herramientas externas.
```

**Qué produce:**
PRD completo con problem/solution/impact, personas, user stories de alto nivel,
requisitos funcionales y no funcionales, criterios de aceptación y out of scope.

---

## Flujo recomendado en Nivel 1

```
1. /plan:ideate  →  Artefacto #1 (15-20 min)
2. /plan:prd     →  PRD por feature (10-15 min)
3. /plan:user-stories → User Stories (10-15 min)
```
