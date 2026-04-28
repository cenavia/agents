# Plan Plugin

Pipeline completo de planificación de producto para Claude Code. Cubre el ciclo desde la ideación hasta tickets técnicos listos para desarrollo, con agentes especializados por rol.

---

## Pipeline de planificación

```
/plan:ideate → /plan:prd → /plan:user-stories → /plan:backlog → /plan:epic → /plan:tickets
   Fase 1         Fase 2          Fase 3             Fase 4        Fase 5       Fase 6
```

Para ejecutar el pipeline completo en una sola sesión guiada: `/plan:pipeline`

---

## Comandos

| Comando | Fase | Rol | Descripción |
|---------|------|-----|-------------|
| `/plan:pipeline` | 1-6 | Orquestador | Pipeline completo guiado paso a paso |
| `/plan:ideate` | 1 | Product Owner | Lluvia de ideas → Artefacto #1 con claves de éxito |
| `/plan:prd` | 2 | Product Manager | Epic/idea → PRD formal completo |
| `/plan:user-stories` | 3 | Business Analyst | PRD → User Stories con criterios de aceptación |
| `/plan:backlog` | 4 | Product Owner | User Stories → Backlog priorizado (P1/P2/P3) |
| `/plan:epic` | 5 | Tech Lead | User Stories → Épicas con diagramas Mermaid |
| `/plan:tickets` | 6 | Tech Lead | Épica → Tickets técnicos ≤3h listos para dev |

---

## Agentes especializados

| Agente | Rol | Cuándo usar |
|--------|-----|-------------|
| `product-owner` | Product Owner | Ideación, personas, priorización de backlog, revisión de PRD |
| `business-analyst` | Business Analyst | User Stories, criterios de aceptación, análisis de requisitos |
| `tech-lead` | Tech Lead / Architect | Épicas, tickets técnicos, BDD, arquitectura, plan de pruebas |

Los agentes se invocan vía `/agents` o cuando Claude los delegue automáticamente.

---

## Skills (invocación directa)

| Skill | Comando | Descripción |
|-------|---------|-------------|
| Product Ideation Brainstorm | `/plan:product-ideation-brainstorm` | Flujo completo de ideación con checklist de calidad |
| Breakdown Feature PRD | `/plan:breakdown-feature-prd` | PRD detallado con plantilla completa |
| Project Manager | `/plan:project-manager` | Gestión completa: US, épicas, tickets, BDD, plan de pruebas |

---

## Instalación local

```bash
claude --plugin-dir /ruta/a/plan
```

Verificar que los skills están disponibles:

```
/plan:pipeline
```

---

## Uso rápido

### Pipeline completo (recomendado)

```
/plan:pipeline
```

El orquestador guía por las 6 fases, confirma cada artefacto y propone el siguiente paso.

### Fase individual — Ejemplo: Backlog

```
/plan:backlog

US-001: Login con email
US-002: Recuperación de contraseña
US-003: Dashboard de métricas
US-004: Exportar reportes a CSV
```

### Agente directo — Ejemplo: Tech Lead

Invocar desde `/agents → tech-lead`:

```
Tengo estas User Stories del módulo de autenticación. Crea la épica con
diagramas y descomponla en tickets técnicos para un stack Node.js + React.

[pegar User Stories aquí]
```

---

## Artefactos que produce el pipeline

| Fase | Artefacto | Formato |
|------|-----------|---------|
| 1 | Claves de éxito + Descripción del sistema | Markdown |
| 2 | PRD completo | Markdown |
| 3 | N User Stories con AC en Gherkin | Markdown |
| 4 | Backlog priorizado con sprints sugeridos | Tabla Markdown |
| 5 | Épicas con diagramas Mermaid | Markdown |
| 6 | Tickets técnicos ≤3h con BDD | Markdown |

---

## Estructura del plugin

```
plan/
├── .claude-plugin/
│   └── plugin.json                          ← manifest v1.1.0
├── agents/
│   ├── product-owner.md                     ← PO: ideación, personas, priorización
│   ├── business-analyst.md                  ← BA: user stories, requisitos, AC
│   └── tech-lead.md                         ← TL: épicas, tickets, BDD, arquitectura
├── commands/
│   ├── pipeline.md                          ← orquestador de las 6 fases
│   ├── ideate.md                            ← Fase 1: ideación
│   ├── prd.md                               ← Fase 2: PRD
│   ├── user-stories.md                      ← Fase 3: user stories
│   ├── backlog.md                           ← Fase 4: priorización
│   ├── epic.md                              ← Fase 5: épicas
│   └── tickets.md                           ← Fase 6: tickets técnicos
├── skills/
│   ├── product-ideation-brainstorm/
│   │   └── SKILL.md
│   ├── breakdown-feature-prd/
│   │   └── SKILL.md
│   └── project-manager/
│       ├── SKILL.md
│       └── references/
│           ├── epic-template.md
│           └── ticket-template.md
└── README.md
```

---

## Licencia

Apache-2.0
