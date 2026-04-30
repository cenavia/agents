# Python Test Infrastructure Setup

You are a Python testing expert. Generate complete testing infrastructure for an existing Python project: pytest configuration, conftest.py with base fixtures, test directory structure, and sample tests following best practices.

## Context

The user needs a ready-to-use test setup for an existing project. Do not rewrite application code — only generate the testing layer. Cover unit tests, integration tests, and the CI job configuration.

## Requirements

$ARGUMENTS

## Instructions

### 1. Detect Project Type

Determine from the project structure or user input:

- **FastAPI** — async test client, database fixtures with rollback, auth mocks
- **Django** — pytest-django, `@pytest.mark.django_db`, factory_boy fixtures
- **Library / CLI** — pure pytest, no web dependencies
- **Generic** — standard pytest setup

### 2. Configure pyproject.toml

Add or update the `[tool.pytest.ini_options]` section:

**FastAPI / async:**

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
filterwarnings = ["error", "ignore::DeprecationWarning"]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "*/migrations/*"]

[tool.coverage.report]
fail_under = 80
show_missing = true
```

**Django:**

```toml
[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings.test"
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = "--reuse-db --strict-markers"

[tool.coverage.run]
source = ["."]
omit = ["*/migrations/*", "manage.py", "config/*"]
```

**Library / Generic:**

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --tb=short"

[tool.coverage.run]
source = ["src"]
```

### 3. Generate conftest.py

**FastAPI conftest.py:**

```python
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

from app.main import app
from app.core.database import Base, get_db

TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest_asyncio.fixture(scope="session")
async def engine():
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()

@pytest_asyncio.fixture
async def db_session(engine):
    async_session = async_sessionmaker(engine, expire_on_commit=False)
    async with async_session() as session:
        async with session.begin():
            yield session
            await session.rollback()

@pytest_asyncio.fixture
async def client(db_session):
    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as ac:
        yield ac
    app.dependency_overrides.clear()

@pytest.fixture
def mock_user():
    return {"id": 1, "email": "test@example.com", "is_active": True}
```

**Django conftest.py:**

```python
import pytest
from django.contrib.auth import get_user_model

User = get_user_model()

@pytest.fixture
def user(db):
    return User.objects.create_user(
        username="testuser",
        email="test@example.com",
        password="testpass123"
    )

@pytest.fixture
def admin_user(db):
    return User.objects.create_superuser(
        username="admin",
        email="admin@example.com",
        password="adminpass123"
    )

@pytest.fixture
def auth_client(client, user):
    client.force_login(user)
    return client

@pytest.fixture
def api_client():
    from rest_framework.test import APIClient
    return APIClient()

@pytest.fixture
def auth_api_client(api_client, user):
    api_client.force_authenticate(user=user)
    return api_client
```

**Generic / Library conftest.py:**

```python
import pytest
from pathlib import Path

@pytest.fixture(scope="session")
def test_data_dir():
    return Path(__file__).parent / "data"

@pytest.fixture
def sample_data():
    return {"key": "value", "count": 42}
```

### 4. Generate Test Directory Structure

```
tests/
├── conftest.py              # Global fixtures
├── unit/
│   ├── __init__.py
│   ├── conftest.py          # Unit-specific fixtures
│   └── test_services.py
├── integration/
│   ├── __init__.py
│   ├── conftest.py          # Integration-specific fixtures
│   └── test_api.py
└── data/                    # Test data files (JSON, CSV, etc.)
```

### 5. Generate Sample Tests

**FastAPI sample (tests/integration/test_api.py):**

```python
import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.asyncio

class TestHealthEndpoint:
    async def test_health_returns_ok(self, client: AsyncClient):
        response = await client.get("/health")
        assert response.status_code == 200

class TestUsersEndpoint:
    async def test_create_user_returns_201(self, client: AsyncClient):
        response = await client.post(
            "/api/v1/users/",
            json={"email": "new@example.com", "password": "pass123"}
        )
        assert response.status_code == 201
        assert response.json()["email"] == "new@example.com"

    async def test_create_user_duplicate_email_returns_400(self, client: AsyncClient):
        payload = {"email": "dup@example.com", "password": "pass123"}
        await client.post("/api/v1/users/", json=payload)
        response = await client.post("/api/v1/users/", json=payload)
        assert response.status_code == 400

    @pytest.mark.parametrize("email", ["", "not-an-email", "missing@"])
    async def test_create_user_invalid_email_returns_422(
        self, client: AsyncClient, email: str
    ):
        response = await client.post(
            "/api/v1/users/",
            json={"email": email, "password": "pass123"}
        )
        assert response.status_code == 422
```

**Unit test sample (tests/unit/test_services.py):**

```python
import pytest
from unittest.mock import AsyncMock, MagicMock

class TestUserService:
    @pytest.fixture
    def mock_repo(self):
        repo = MagicMock()
        repo.get_by_email = AsyncMock(return_value=None)
        repo.create = AsyncMock()
        return repo

    async def test_create_user_hashes_password(self, mock_repo):
        from app.services.user_service import UserService
        service = UserService(repository=mock_repo)
        await service.create_user(db=AsyncMock(), email="u@test.com", password="plain")
        call_args = mock_repo.create.call_args
        assert call_args.kwargs.get("hashed_password") != "plain"

    async def test_create_user_raises_on_duplicate(self, mock_repo):
        from app.services.user_service import UserService
        mock_repo.get_by_email = AsyncMock(return_value={"id": 1})
        service = UserService(repository=mock_repo)
        with pytest.raises(ValueError, match="already registered"):
            await service.create_user(db=AsyncMock(), email="u@test.com", password="p")
```

### 6. Add Dev Dependencies

```bash
# FastAPI project
uv add --dev pytest pytest-asyncio httpx pytest-cov aiosqlite

# Django project
uv add --dev pytest pytest-django pytest-cov factory-boy

# Library / Generic
uv add --dev pytest pytest-cov pytest-mock
```

### 7. Add Makefile Targets

```makefile
test:
	uv run pytest -v

test-cov:
	uv run pytest --cov --cov-report=term-missing --cov-report=html

test-unit:
	uv run pytest tests/unit/ -v

test-integration:
	uv run pytest tests/integration/ -v
```

## Output Format

1. **pyproject.toml additions** — `[tool.pytest.ini_options]` and `[tool.coverage.*]`
2. **conftest.py** — top-level and per-directory where needed
3. **Test directory structure** — with `__init__.py` files
4. **Sample tests** — integration and unit, matching the project's domain
5. **Dev dependencies** — `uv add --dev` commands
6. **Makefile targets** — `test`, `test-cov`, `test-unit`, `test-integration`

Generate only what matches the detected project type. Do not create application files.
