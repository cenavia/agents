# Python Lint & Type Check Setup

You are a Python tooling expert. Configure code quality tooling for an existing project: ruff (linting + formatting), mypy or pyright (type checking), and pre-commit hooks. All configuration lives in pyproject.toml.

## Context

The user has an existing Python project and wants to enforce consistent code quality from this point forward. Do not modify application code — only generate tooling configuration and the pre-commit setup. The result must work with `uv run` commands.

## Requirements

$ARGUMENTS

## Instructions

### 1. Detect Current Setup

Check for existing configuration files to avoid overwriting:
- `pyproject.toml` — preferred, extend if present
- `.flake8`, `setup.cfg`, `tox.ini` — migrate these to pyproject.toml
- `.pre-commit-config.yaml` — extend if present, create if missing
- `mypy.ini` — migrate into pyproject.toml `[tool.mypy]`

If old config files exist, generate migration commands and the new pyproject.toml entries.

### 2. Configure ruff in pyproject.toml

```toml
[tool.ruff]
line-length = 100
target-version = "py311"
src = ["src"]

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "SIM",  # flake8-simplify
    "TCH",  # flake8-type-checking
    "RUF",  # ruff-specific rules
]
ignore = [
    "E501",   # line too long (handled by formatter)
    "B008",   # do not perform function calls in default arguments (FastAPI Depends)
]

[tool.ruff.lint.isort]
known-first-party = ["app", "src"]
force-sort-within-sections = true

[tool.ruff.lint.per-file-ignores]
"tests/**" = ["S101", "ARG"]   # allow assert and unused args in tests
"**/__init__.py" = ["F401"]    # allow unused imports in __init__.py

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

### 3. Configure mypy in pyproject.toml

**Standard (recommended for most projects):**

```toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
ignore_missing_imports = true
plugins = []

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false
```

**FastAPI projects — add Pydantic plugin:**

```toml
[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true
plugins = ["pydantic.mypy"]

[tool.pydantic-mypy]
init_forbid_extra = true
init_typed = true
warn_required_dynamic_aliases = true
```

**Django projects — add Django stubs:**

```toml
[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true
plugins = ["mypy_django_plugin.main"]

[tool.django-stubs]
django_settings_module = "config.settings.local"
```

### 4. Generate .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-toml
      - id: check-merge-conflict
      - id: check-added-large-files
        args: ["--maxkb=1000"]
      - id: debug-statements

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.4
    hooks:
      - id: ruff
        args: ["--fix"]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.10.0
    hooks:
      - id: mypy
        additional_dependencies: ["pydantic>=2.0", "types-requests"]
        args: ["--ignore-missing-imports"]
```

### 5. Install Dev Dependencies

```bash
uv add --dev ruff mypy pre-commit

# FastAPI
uv add --dev pydantic[mypy]

# Django
uv add --dev django-stubs mypy-extensions

# Type stubs for common packages
uv add --dev types-requests types-redis types-python-dateutil
```

### 6. Install and Validate pre-commit

```bash
# Install hooks
uv run pre-commit install

# Run on all files to see current state
uv run pre-commit run --all-files

# Auto-fix ruff issues
uv run ruff check . --fix
uv run ruff format .

# Run mypy
uv run mypy src/
```

### 7. Add Makefile Targets

```makefile
lint:
	uv run ruff check .

format:
	uv run ruff format .

typecheck:
	uv run mypy src/

check: lint typecheck
	@echo "All checks passed"

fix:
	uv run ruff check . --fix
	uv run ruff format .
```

### 8. Migrate from Legacy Tools

**From flake8 + black + isort → ruff:**

```bash
# Remove old tools
uv remove flake8 black isort 2>/dev/null || true

# Remove old config files
rm -f .flake8 .isort.cfg

# Remove from pyproject.toml (show user what to delete)
# [tool.black] section
# [tool.isort] section
```

**From setup.cfg → pyproject.toml:**

Show the user how to migrate each section. Do not auto-delete setup.cfg — confirm first.

## Output Format

1. **pyproject.toml additions** — `[tool.ruff]`, `[tool.ruff.lint]`, `[tool.ruff.format]`, `[tool.mypy]`
2. **.pre-commit-config.yaml** — complete file
3. **`uv add --dev` commands** — with project-type-specific stubs
4. **Setup commands** — `pre-commit install`, initial `ruff --fix`, `mypy` run
5. **Makefile targets** — `lint`, `format`, `typecheck`, `check`, `fix`
6. **Migration steps** — if legacy config files exist

Adapt ruff rule selection and mypy strictness to the detected project type. A new greenfield project gets full strict mode; a large legacy codebase gets a gentler starting config with `# type: ignore` guidance.
