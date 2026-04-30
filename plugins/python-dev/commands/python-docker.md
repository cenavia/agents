# Python Docker Setup

You are a Python DevOps expert. Generate production-ready Docker configuration for a Python project: multi-stage Dockerfile, docker-compose.yml for local development, and .dockerignore. Optimized for image size, build cache, and security.

## Context

The user needs Docker configuration for an existing Python project managed with uv. Do not modify application code. The Dockerfile must work with `uv` for dependency installation and produce lean, non-root images.

## Requirements

$ARGUMENTS

## Instructions

### 1. Detect Project Type

- **FastAPI / ASGI** — uvicorn entrypoint, async-ready
- **Django** — gunicorn + uvicorn worker, static files handling
- **CLI tool** — single entrypoint binary
- **Library** — no Dockerfile needed, skip to packaging advice

### 2. Generate Dockerfile (FastAPI)

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# --- deps stage: install dependencies only ---
FROM base AS deps

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

# --- build stage: install project ---
FROM deps AS build

COPY src/ ./src/
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# --- runtime stage: lean final image ---
FROM base AS runtime

RUN addgroup --system app && adduser --system --ingroup app app

COPY --from=build --chown=app:app /app/.venv /app/.venv

WORKDIR /app
COPY --chown=app:app src/ ./src/

USER app
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

### 3. Generate Dockerfile (Django)

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    DJANGO_SETTINGS_MODULE=config.settings.production

WORKDIR /app

FROM base AS deps

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

FROM deps AS build

COPY . .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

FROM base AS runtime

RUN addgroup --system django && adduser --system --ingroup django django

COPY --from=build --chown=django:django /app/.venv /app/.venv
COPY --chown=django:django . .

USER django
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000

RUN python manage.py collectstatic --noinput

CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", \
     "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker"]
```

### 4. Generate docker-compose.yml

**FastAPI + PostgreSQL + Redis:**

```yaml
services:
  api:
    build:
      context: .
      target: runtime
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql+asyncpg://postgres:postgres@db:5432/appdb
      REDIS_URL: redis://redis:6379/0
      SECRET_KEY: dev-secret-key-change-in-production
      DEBUG: "true"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./src:/app/src   # hot reload in dev
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  postgres_data:
```

**Django + PostgreSQL + Celery:**

```yaml
services:
  web:
    build:
      context: .
      target: runtime
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/appdb
      CELERY_BROKER_URL: redis://redis:6379/0
      DJANGO_SETTINGS_MODULE: config.settings.local
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - .:/app
    command: python manage.py runserver 0.0.0.0:8000

  worker:
    build:
      context: .
      target: runtime
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/appdb
      CELERY_BROKER_URL: redis://redis:6379/0
      DJANGO_SETTINGS_MODULE: config.settings.local
    depends_on:
      - db
      - redis
    command: celery -A config worker --loglevel=info

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine

volumes:
  postgres_data:
```

### 5. Generate .dockerignore

```
# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
.Python
*.egg-info/
dist/
build/
.eggs/

# Virtual environments
.venv/
venv/
env/

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/

# Dev tooling
.ruff_cache/
.mypy_cache/
.git/
.gitignore

# IDE
.vscode/
.idea/
*.swp

# Docs
docs/
*.md

# Environment files (NEVER copy secrets)
.env
.env.*
!.env.example

# CI
.github/
```

### 6. Add Makefile Targets

```makefile
docker-build:
	docker build --target runtime -t app:latest .

docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f api

docker-shell:
	docker compose exec api /bin/bash
```

## Output Format

1. **Dockerfile** — multi-stage, matched to project type
2. **docker-compose.yml** — with all required services and healthchecks
3. **.dockerignore** — complete file
4. **Makefile targets** — build, up, down, logs, shell
5. **Build verification** — `docker build` command to test the output

Always explain the stage rationale (base → deps → build → runtime) so the user understands the cache optimization.
