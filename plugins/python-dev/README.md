# python-dev

Toolkit de Claude Code para desarrollo Python de producción. Cubre el ciclo completo: scaffolding → feature generation → auth → observabilidad → testing → CI/CD.

---

## Instalación

```bash
claude --plugin-dir ./python-dev
```

Para usarlo en cualquier proyecto:

```bash
claude --plugin-dir /ruta/absoluta/python-dev
```

---

## Componentes

| Capa | Qué es | Cuándo usar |
|------|--------|-------------|
| **Commands** | Slash commands que generan implementaciones completas | Cuando quieres construir o agregar algo concreto |
| **Skills** | Referencia técnica que Claude inyecta automáticamente | Mientras escribes código — se activan solos |
| **Agents** | Subagentes especializados con dominio único | Para trabajo iterativo en un área específica |

---

## Commands

Cada command tiene un propósito único y no se superpone con otro.

### `/python-dev:python-scaffold` — proyecto nuevo

Genera una aplicación Python completa desde cero. Detecta el tipo y produce estructura, pyproject.toml, entry point, tests y Makefile.

```
/python-dev:python-scaffold FastAPI microservicio de pagos con PostgreSQL y JWT
/python-dev:python-scaffold Django e-commerce con panel admin y Celery
/python-dev:python-scaffold librería Python para parsing de logs, publicar en PyPI
/python-dev:python-scaffold CLI tool de análisis de datos con Typer y Rich
```

---

### `/python-dev:python-scaffold-graphql` — proyecto GraphQL nuevo

Genera un proyecto GraphQL completo desde cero. Soporta tres stacks — detecta cuál usar desde los argumentos o pregunta antes de generar.

| Stack | Cuándo usarlo |
|-------|--------------|
| **Strawberry + FastAPI** | Proyecto nuevo, async, type-safe, code-first |
| **graphene-django** | Django existente, Relay pagination, admin integration |
| **Ariadne + FastAPI** | Schema-first obligatorio, SDL compartido con otros equipos |

```
/python-dev:python-scaffold-graphql Strawberry + FastAPI con PostgreSQL y JWT
/python-dev:python-scaffold-graphql graphene-django con Relay y autenticación JWT
/python-dev:python-scaffold-graphql Ariadne schema-first con FastAPI
```

Genera (Strawberry + FastAPI):
- Estructura `graphql/` con `types/`, `queries/`, `mutations/`, `subscriptions/`
- `dataloaders.py` — DataLoader para prevenir N+1 desde el inicio
- `context.py` — contexto tipado con db session y current_user
- `schema.py` — schema raíz que combina todos los resolvers
- Tests con `AsyncClient` y queries GraphQL reales
- pyproject.toml con dependencias exactas y versiones compatibles

---

### `/python-dev:python-add-feature` — nueva feature desde la arquitectura del proyecto

Genera una feature completa (modelo → schema → repositorio → servicio → endpoint → tests) leyendo primero el código existente y replicando sus convenciones exactas. No usa patrones genéricos — sigue los del proyecto.

**La diferencia clave con `python-scaffold`:** scaffold genera estructura vacía desde cero; este command lee lo que ya existe y produce código que parece escrito por el mismo autor.

```
/python-dev:python-add-feature orders con campos: user_id, items[], total, status
/python-dev:python-add-feature products con name, price, stock, category_id. Solo GET y POST
/python-dev:python-add-feature notifications con user_id, message, read, type. Sin delete
```

Flujo interno:
1. **Lee** un recurso existente (p.ej. `users`) como referencia de convenciones
2. **Extrae** base classes, naming, DI pattern, error types, fixtures de tests
3. **Genera** todos los archivos siguiendo esas convenciones
4. **Entrega** checklist de integración: router registration, migrations, `__init__.py`

Genera:
- `models/<entity>.py` — ORM model con la base class del proyecto
- `schemas/<entity>.py` — Pydantic schemas Base/Create/Update/Read
- `repositories/<entity>_repository.py` — repo siguiendo el patrón del proyecto
- `services/<entity>_service.py` — solo si el proyecto usa service layer
- `api/v1/endpoints/<entity>.py` — router con el mismo estilo de errores y response_model
- `tests/integration/test_<entity>.py` + `tests/unit/test_<entity>_service.py`
- Comando de migración Alembic si el proyecto lo usa

---

### `/python-dev:python-test-setup` — infraestructura de tests

Agrega pytest a un proyecto existente. Genera conftest.py, fixtures base, estructura de directorios y tests de ejemplo. No modifica código de aplicación.

```
/python-dev:python-test-setup proyecto FastAPI con SQLAlchemy async y auth JWT
/python-dev:python-test-setup aplicación Django REST con factory_boy
/python-dev:python-test-setup librería Python genérica con Hypothesis
```

Genera:
- `[tool.pytest.ini_options]` y `[tool.coverage.*]` en pyproject.toml
- `tests/conftest.py` con fixtures apropiados al framework
- `tests/unit/` e `tests/integration/` con samples
- `uv add --dev` con las dependencias correctas
- Targets `test`, `test-cov` en Makefile

---

### `/python-dev:python-lint-setup` — calidad de código

Configura ruff, mypy y pre-commit en un proyecto existente. Migra configuraciones legacy (flake8, black, isort, setup.cfg) a pyproject.toml.

```
/python-dev:python-lint-setup proyecto FastAPI con Pydantic
/python-dev:python-lint-setup proyecto Django con django-stubs
/python-dev:python-lint-setup librería nueva, modo strict completo
/python-dev:python-lint-setup proyecto legacy con flake8 + black, migrar a ruff
```

Genera:
- `[tool.ruff]`, `[tool.ruff.lint]`, `[tool.ruff.format]` en pyproject.toml
- `[tool.mypy]` con plugin Pydantic o Django según corresponda
- `.pre-commit-config.yaml` completo
- Comandos de migración si hay configuración legacy
- Targets `lint`, `format`, `typecheck`, `fix` en Makefile

---

### `/python-dev:python-docker` — contenedores

Genera Dockerfile multi-stage optimizado, docker-compose.yml con servicios y .dockerignore. El Dockerfile usa uv y corre como usuario non-root.

```
/python-dev:python-docker FastAPI con PostgreSQL y Redis
/python-dev:python-docker Django con Celery, PostgreSQL y Redis
/python-dev:python-docker FastAPI sin base de datos, solo API pura
```

Genera:
- `Dockerfile` en 4 stages: base → deps → build → runtime
- `docker-compose.yml` con servicios, healthchecks y volumes
- `.dockerignore`
- Targets `docker-build`, `docker-up`, `docker-down` en Makefile

---

### `/python-dev:python-ci` — pipeline CI/CD

Genera GitHub Actions para lint, typecheck, tests con coverage y opcionalmente Docker build y publish a PyPI.

```
/python-dev:python-ci FastAPI con PostgreSQL, coverage a Codecov
/python-dev:python-ci librería Python, matrix 3.11/3.12/3.13, publish a PyPI
/python-dev:python-ci proyecto sin base de datos, solo lint y tests
```

Genera:
- `.github/workflows/ci.yml` con jobs `lint` y `test`
- Servicios Postgres/Redis en CI si el proyecto los necesita
- `.github/workflows/publish.yml` solo para bibliotecas
- Job de Docker build si existe Dockerfile
- Instrucciones de branch protection para GitHub

---

### `/python-dev:python-add-auth` — autenticación

Agrega un sistema de auth completo a un proyecto FastAPI o Django existente. No modifica modelos existentes — solo genera la capa de auth.

```
/python-dev:python-add-auth FastAPI JWT con refresh tokens
/python-dev:python-add-auth FastAPI API key en header X-API-Key
/python-dev:python-add-auth Django REST con SimpleJWT
```

Genera:
- `core/security.py` — hash, verify, create/decode tokens
- `api/deps.py` — `get_current_user`, `require_role`
- `api/v1/endpoints/auth.py` — login y refresh
- `schemas/auth.py` — Token y TokenRefresh
- Adiciones a config.py y .env.example

---

### `/python-dev:python-add-observability` — observabilidad

Agrega logging estructurado, tracing distribuido y métricas Prometheus a un proyecto existente. Cada pilar es opcional.

```
/python-dev:python-add-observability FastAPI, solo logging estructurado
/python-dev:python-add-observability FastAPI, los tres pilares: logging + tracing + metrics
/python-dev:python-add-observability Django, structured logging con correlación de requests
```

Genera:
- `core/logging.py` — structlog con JSON output
- `api/middleware/logging.py` — correlation ID + request log
- `core/tracing.py` — OpenTelemetry con OTLP exporter
- `api/middleware/metrics.py` — Prometheus + endpoint `/metrics`
- Adiciones a docker-compose para Jaeger, Prometheus, Grafana

---

## Agentes especializados

Cada agente tiene un dominio único. La tabla de decisión elimina la ambigüedad.

### Tabla de decisión

| Tarea | Agente |
|-------|--------|
| Configurar uv, ruff, mypy, pre-commit | `python-pro` |
| Publicar librería en PyPI | `python-pro` |
| Migrar pip → uv, setup.py → pyproject.toml | `python-pro` |
| Implementar endpoint FastAPI | `fastapi-pro` |
| Resolver N+1 en SQLAlchemy | `fastapi-pro` |
| JWT, OAuth2, rate limiting en FastAPI | `fastapi-pro` |
| WebSocket en FastAPI | `fastapi-pro` |
| Vista Django, ORM, migrations | `django-pro` |
| Django Channels, Celery, deployment | `django-pro` |
| Diseñar boundaries entre servicios | `backend-architect` |
| Elegir entre REST, GraphQL o gRPC | `backend-architect` |
| Schema GraphQL con Federation | `backend-architect` |
| Event-driven con Kafka/RabbitMQ | `backend-architect` |
| Circuit breaker, saga pattern | `backend-architect` |

### Cuándo usar cada agente

**`python-pro`** — Python como lenguaje y tooling:
```
migra este proyecto de pip + setup.py a uv + pyproject.toml
y configura ruff strict + mypy + pre-commit
```

**`fastapi-pro`** — implementación dentro de una FastAPI app:
```
este endpoint tiene N+1 queries con SQLAlchemy async.
diagnostica y optimiza con eager loading
```

**`django-pro`** — implementación dentro de una Django app:
```
agrega async views y Django Channels para notificaciones
en tiempo real a esta app existente
```

**`backend-architect`** — diseño de sistemas, decisiones de arquitectura:
```
diseña la arquitectura para desacoplar este monolito en
servicios independientes. necesito decidir entre REST y
GraphQL para la API pública
```

---

## Skills automáticos

Se activan solos según el código que estés escribiendo.

| Código que escribes | Skill que se activa |
|---------------------|---------------------|
| `from fastapi import`, `@app.get(`, `Depends(` | `fastapi-templates` |
| `async def`, `await`, `asyncio.gather` | `async-python-patterns` |
| `import pytest`, `@pytest.fixture` | `python-testing-patterns` |
| `pyproject.toml`, `uv add`, `uv sync` | `uv-package-manager` |
| `BaseModel`, `model_validator`, `Protocol` | `python-type-safety` |
| `@retry`, `tenacity`, `wait_exponential` | `python-resilience` |
| `structlog`, `logging.getLogger`, `@traceable` | `python-observability` |
| `Celery`, `task.delay()`, `@shared_task` | `python-background-jobs` |
| `__enter__`, `__exit__`, `contextmanager` | `python-resource-management` |
| `class.*Error(Exception)`, `raise.*from` | `python-error-handling` |
| `TypeVar`, `Generic[T]`, `Protocol` | `python-type-safety` |
| `BaseSettings`, `pydantic_settings` | `python-configuration` |
| `hatchling`, `build-backend`, `[tool.hatch` | `python-packaging` |
| `cProfile`, `line_profiler`, `timeit` | `python-performance-optimization` |
| `SOLID`, `Factory`, `Repository` | `python-design-patterns` |
| `__all__`, `src/`, layered architecture | `python-project-structure` |
| `ruff`, `mypy`, `isort` | `python-code-style` |
| Anti-patterns checklist | `python-anti-patterns` |

---

## Flujos de trabajo completos

### FastAPI en producción (desde cero)

```
1. /python-dev:python-scaffold FastAPI payments service con PostgreSQL
   → src/, pyproject.toml, main.py, config.py

2. /python-dev:python-add-auth JWT con refresh tokens
   → core/security.py, deps.py, auth endpoints

3. /python-dev:python-test-setup FastAPI con SQLAlchemy async
   → conftest.py, db fixtures, integration tests

4. /python-dev:python-add-observability logging + metrics
   → structlog middleware, Prometheus /metrics

5. /python-dev:python-lint-setup con Pydantic plugin
   → ruff, mypy, pre-commit

6. /python-dev:python-docker FastAPI + PostgreSQL + Redis
   → Dockerfile multi-stage, docker-compose

7. /python-dev:python-ci con PostgreSQL, coverage a Codecov
   → .github/workflows/ci.yml
```

### Mejorar proyecto existente

```
1. /python-dev:python-lint-setup → migrar flake8 + black a ruff + mypy

2. /python-dev:python-test-setup → agregar tests faltantes con fixtures

3. Agente python-pro → auditar pyproject.toml y migrar a uv

4. /python-dev:python-add-observability → logging estructurado

5. /python-dev:python-ci → pipeline CI/CD con gate de cobertura
```

### Librería Python para PyPI

```
1. /python-dev:python-scaffold librería con hatchling
   → source layout, pyproject.toml, py.typed

2. /python-dev:python-lint-setup modo strict
   → ruff + mypy strict + pre-commit

3. /python-dev:python-test-setup con Hypothesis
   → pytest, property-based tests, coverage

4. /python-dev:python-ci matrix 3.11/3.12/3.13 + publish
   → ci.yml + publish.yml con trusted publishing
```

---

## Referencia rápida

```bash
# Commands disponibles
/python-dev:python-scaffold          # Proyecto nuevo (FastAPI/Django/Library/CLI)
/python-dev:python-scaffold-graphql  # Proyecto GraphQL (Strawberry/graphene-django/Ariadne)
/python-dev:python-add-feature       # Nueva feature leyendo la arquitectura del proyecto
/python-dev:python-test-setup        # Infraestructura de tests para proyecto existente
/python-dev:python-lint-setup        # ruff + mypy + pre-commit
/python-dev:python-docker            # Dockerfile multi-stage + docker-compose
/python-dev:python-ci                # GitHub Actions CI/CD
/python-dev:python-add-auth          # JWT / API key / SimpleJWT
/python-dev:python-add-observability # structlog + OpenTelemetry + Prometheus

# Agentes disponibles
python-pro          # Tooling: uv, ruff, mypy, packaging, Python puro
fastapi-pro         # Implementación FastAPI: endpoints, SQLAlchemy, auth, tests
django-pro          # Implementación Django: vistas, ORM, Channels, Celery
backend-architect   # Diseño: boundaries, API contracts, GraphQL, event-driven
```
