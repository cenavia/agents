# Python CI/CD Pipeline

You are a Python DevOps expert. Generate a complete GitHub Actions CI/CD pipeline for a Python project: lint, typecheck, test with coverage, optional Docker build, and optional PyPI publish.

## Context

The user needs GitHub Actions workflows for an existing Python project using uv. Generate `.github/workflows/ci.yml` and optionally `.github/workflows/publish.yml`. Use uv for all Python operations. Cache aggressively to minimize CI time.

## Requirements

$ARGUMENTS

## Instructions

### 1. Detect Project Needs

From the user input or project structure, determine:

- **Test framework**: pytest (default), pytest-asyncio for async projects
- **Publish to PyPI**: yes if it's a library with `[build-system]` in pyproject.toml
- **Docker build**: yes if Dockerfile exists
- **Coverage gate**: default 80%, adjustable
- **Python versions**: default 3.11 + 3.12, add 3.13 for libraries

### 2. Generate .github/workflows/ci.yml

**FastAPI / Django (single Python version):**

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  PYTHON_VERSION: "3.12"

jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v3
        with:
          enable-cache: true

      - name: Set up Python
        run: uv python install ${{ env.PYTHON_VERSION }}

      - name: Install dependencies
        run: uv sync --frozen --dev

      - name: Run ruff (lint)
        run: uv run ruff check .

      - name: Run ruff (format check)
        run: uv run ruff format --check .

      - name: Run mypy
        run: uv run mypy src/

  test:
    name: Tests
    runs-on: ubuntu-latest
    needs: lint

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: testdb
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 5s
          --health-timeout 3s
          --health-retries 5

    env:
      DATABASE_URL: postgresql+asyncpg://postgres:postgres@localhost:5432/testdb
      REDIS_URL: redis://localhost:6379/0
      SECRET_KEY: ci-test-secret-key

    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v3
        with:
          enable-cache: true

      - name: Set up Python
        run: uv python install ${{ env.PYTHON_VERSION }}

      - name: Install dependencies
        run: uv sync --frozen --dev

      - name: Run tests with coverage
        run: uv run pytest --cov --cov-report=xml --cov-report=term-missing

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          fail_ci_if_error: false
```

**Library (matrix across Python versions):**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
        with:
          enable-cache: true
      - run: uv python install 3.12
      - run: uv sync --frozen --dev
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run mypy src/

  test:
    name: Test Python ${{ matrix.python-version }}
    runs-on: ubuntu-latest
    needs: lint
    strategy:
      fail-fast: false
      matrix:
        python-version: ["3.11", "3.12", "3.13"]

    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v3
        with:
          enable-cache: true

      - name: Set up Python ${{ matrix.python-version }}
        run: uv python install ${{ matrix.python-version }}

      - name: Install dependencies
        run: uv sync --frozen --dev

      - name: Run tests
        run: uv run pytest --cov --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        if: matrix.python-version == '3.12'
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
```

### 3. Generate .github/workflows/publish.yml (Libraries only)

```yaml
name: Publish to PyPI

on:
  release:
    types: [published]

jobs:
  build:
    name: Build distribution
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v3

      - name: Build package
        run: uv build

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  publish-pypi:
    name: Publish to PyPI
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: pypi
      url: https://pypi.org/p/${{ github.event.repository.name }}
    permissions:
      id-token: write   # trusted publishing — no API token needed

    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/

      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
```

### 4. Add Docker Build Job (optional)

Append to ci.yml if a Dockerfile exists:

```yaml
  docker:
    name: Docker Build
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build image
        uses: docker/build-push-action@v6
        with:
          context: .
          target: runtime
          push: false
          tags: app:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### 5. Branch Protection Recommendation

After generating the workflow, remind the user to set branch protection rules on `main`:

```
Settings → Branches → Add rule:
  ✅ Require status checks to pass before merging
      Required checks: lint, test (all matrix versions)
  ✅ Require branches to be up to date before merging
  ✅ Do not allow bypassing the above settings
```

## Output Format

1. **.github/workflows/ci.yml** — lint + test jobs, matched to project type
2. **.github/workflows/publish.yml** — only for libraries
3. **Docker build job** — appended to ci.yml if Dockerfile exists
4. **Branch protection instructions** — what to configure in GitHub settings
5. **Required GitHub secrets** — list what secrets need to be set (`CODECOV_TOKEN`, etc.)

Omit the Postgres/Redis services block if the project uses SQLite for testing. Omit the coverage upload step if `CODECOV_TOKEN` is not mentioned. Always use `astral-sh/setup-uv@v3` — never `actions/setup-python` + pip.
