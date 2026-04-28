# ng-kit — Angular Plugin for Claude Code

Plugin completo para desarrollo frontend con Angular. Desde el primer `ng new` hasta el PR listo: landing pages, features, tests, code review y migración a signals.

---

## Skills (slash commands con namespace)

| Comando | Descripción |
|---|---|
| `/ng-kit:angular-new-app` | Crea una nueva app Angular paso a paso con best practices |
| `/ng-kit:angular-developer` | Guía experta: componentes, signals, forms, routing, DI, testing, styling |

---

## Comandos rápidos

| Comando | Descripción |
|---|---|
| `/ng-kit:scaffold-landing <descripción>` | Crea un proyecto Angular completo con landing page funcional (hero, features, pricing, footer) |
| `/ng-kit:new-feature <descripción>` | Scaffoldea una feature completa (componente + servicio + ruta lazy) |
| `/ng-kit:add-tests <archivo>` | Genera tests unitarios para un componente o servicio |
| `/ng-kit:migrate-signals <archivo>` | Migra código legacy (BehaviorSubject, ngModel, @Input) a signals |
| `/ng-kit:fix-build [error]` | Diagnostica y repara errores de compilación Angular |
| `/ng-kit:review-angular <archivo>` | Code review enfocado en correctness, performance, seguridad y a11y |

---

## Agentes especializados

Los agentes aparecen en `/agents` y Claude los invoca automáticamente cuando el contexto lo requiere.

| Agente | Cuándo se activa |
|---|---|
| `angular-architect` | Diseño de estructura de la app, decisiones de estado, planning de migración |
| `angular-tester` | Escritura y revisión de tests (unit, harness, E2E) |
| `angular-reviewer` | Code review de PRs con veredicto final |

---

## Uso local

```bash
# Cargar el plugin
claude --plugin-dir ./angular-plugin

# Recargar tras cambios (dentro de Claude Code)
/reload-plugins
```

## Requisitos

- Node.js y npm
- Acceso a internet (Angular CLI via npx)

## Versión

1.2.0 — License: MIT
