# GraphQL Project Scaffolding

You are a Python GraphQL expert. Generate a complete, production-ready GraphQL project based on the requested stack. Cover schema definition, resolvers, DataLoader for N+1 prevention, authentication, and testing.

## Context

The user wants to bootstrap a new GraphQL API in Python. Three stacks are supported — detect from `$ARGUMENTS` which one to use and generate the full project structure. If the stack is not specified, recommend Strawberry + FastAPI and explain the trade-offs before proceeding.

## Requirements

$ARGUMENTS

## Stack Selection

| Stack | Use when |
|-------|----------|
| **Strawberry + FastAPI** | New project, async first, code-first types, full type safety |
| **graphene-django** | Django project, Relay pagination, admin integration, existing ORM models |
| **Ariadne + FastAPI** | SDL schema-first is required, multi-language team sharing the schema |

If the stack is ambiguous, ask before generating.

---

## Stack 1 — Strawberry + FastAPI (code-first, recommended)

### Project Structure

```
project-name/
├── pyproject.toml
├── .env.example
├── .gitignore
├── src/
│   └── app/
│       ├── __init__.py
│       ├── main.py
│       ├── config.py
│       ├── core/
│       │   ├── __init__.py
│       │   ├── database.py
│       │   └── security.py
│       ├── graphql/
│       │   ├── __init__.py
│       │   ├── schema.py          # Root schema: combines Query + Mutation + Subscription
│       │   ├── context.py         # GraphQL context: request, db, current_user
│       │   ├── dataloaders.py     # DataLoader definitions
│       │   ├── types/
│       │   │   ├── __init__.py
│       │   │   ├── user.py        # UserType, UserConnection
│       │   │   └── scalars.py     # Custom scalars (DateTime, JSON, UUID)
│       │   ├── queries/
│       │   │   ├── __init__.py
│       │   │   └── user.py        # Query resolvers
│       │   ├── mutations/
│       │   │   ├── __init__.py
│       │   │   └── user.py        # Mutation resolvers
│       │   └── subscriptions/
│       │       ├── __init__.py
│       │       └── user.py        # Subscription resolvers (async generator)
│       ├── models/
│       │   └── user.py
│       └── repositories/
│           └── user_repository.py
└── tests/
    ├── conftest.py
    ├── graphql/
    │   ├── test_queries.py
    │   └── test_mutations.py
    └── data/
        └── queries/
            └── user.graphql       # Stored test queries
```

### pyproject.toml

```toml
[project]
name = "project-name"
version = "0.1.0"
description = "GraphQL API with Strawberry and FastAPI"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.30.0",
    "strawberry-graphql[fastapi]>=0.235.0",
    "sqlalchemy>=2.0.0",
    "alembic>=1.13.0",
    "asyncpg>=0.29.0",
    "pydantic-settings>=2.3.0",
    "pyjwt[crypto]>=2.8.0",
    "passlib[bcrypt]>=1.7.4",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.2.0",
    "pytest-asyncio>=0.23.0",
    "httpx>=0.27.0",
    "aiosqlite>=0.20.0",
    "ruff>=0.4.0",
    "mypy>=1.10.0",
]

[tool.ruff]
line-length = 100
target-version = "py311"
src = ["src"]

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "RUF"]
ignore = ["B008"]

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
```

### src/app/config.py

```python
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "GraphQL API"
    DATABASE_URL: str
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    DEBUG: bool = False

    model_config = SettingsConfigDict(env_file=".env")


@lru_cache
def get_settings() -> Settings:
    return Settings()
```

### src/app/core/database.py

```python
from collections.abc import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase
from app.config import get_settings

settings = get_settings()

engine = create_async_engine(settings.DATABASE_URL, echo=settings.DEBUG)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)


class Base(DeclarativeBase):
    pass


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### src/app/graphql/context.py

```python
from dataclasses import dataclass, field
from typing import Optional
from fastapi import Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession
from strawberry.fastapi import BaseContext
from app.core.database import get_db
from app.graphql.dataloaders import Dataloaders, build_dataloaders
from app.models.user import User


@dataclass
class GraphQLContext(BaseContext):
    db: AsyncSession = field(default=None)  # type: ignore[assignment]
    current_user: Optional[User] = None
    dataloaders: Dataloaders = field(default=None)  # type: ignore[assignment]


async def get_context(
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> GraphQLContext:
    from app.core.security import get_user_from_request

    current_user = await get_user_from_request(request, db)
    return GraphQLContext(
        request=request,
        db=db,
        current_user=current_user,
        dataloaders=build_dataloaders(db),
    )
```

### src/app/graphql/dataloaders.py

```python
from dataclasses import dataclass
from typing import Sequence
from strawberry.dataloader import DataLoader
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.user import User


async def load_users_by_id(
    keys: Sequence[int],
    db: AsyncSession,
) -> list[User | None]:
    """Batch-load users by ID — prevents N+1 on user fields."""
    result = await db.execute(select(User).where(User.id.in_(keys)))
    users_by_id = {u.id: u for u in result.scalars().all()}
    return [users_by_id.get(key) for key in keys]


@dataclass
class Dataloaders:
    user_by_id: DataLoader[int, User | None]


def build_dataloaders(db: AsyncSession) -> Dataloaders:
    return Dataloaders(
        user_by_id=DataLoader(
            load_fn=lambda keys: load_users_by_id(keys, db)
        )
    )
```

### src/app/graphql/types/user.py

```python
from datetime import datetime
from typing import Annotated, Optional
import strawberry
from strawberry import auto
from app.models.user import User as UserModel


@strawberry.type
class UserType:
    id: int
    email: str
    name: str
    is_active: bool
    created_at: datetime

    @classmethod
    def from_model(cls, model: UserModel) -> "UserType":
        return cls(
            id=model.id,
            email=model.email,
            name=model.name,
            is_active=model.is_active,
            created_at=model.created_at,
        )


@strawberry.input
class CreateUserInput:
    email: str
    name: str
    password: str


@strawberry.input
class UpdateUserInput:
    name: Optional[str] = None
    is_active: Optional[bool] = None
```

### src/app/graphql/queries/user.py

```python
from typing import Optional
import strawberry
from strawberry.types import Info
from app.graphql.context import GraphQLContext
from app.graphql.types.user import UserType
from app.repositories.user_repository import UserRepository


@strawberry.type
class UserQuery:

    @strawberry.field
    async def me(self, info: Info[GraphQLContext, None]) -> Optional[UserType]:
        """Return the currently authenticated user."""
        if not info.context.current_user:
            return None
        return UserType.from_model(info.context.current_user)

    @strawberry.field
    async def user(self, info: Info[GraphQLContext, None], id: int) -> Optional[UserType]:
        """Fetch user by ID using DataLoader (no N+1)."""
        model = await info.context.dataloaders.user_by_id.load(id)
        return UserType.from_model(model) if model else None

    @strawberry.field
    async def users(self, info: Info[GraphQLContext, None]) -> list[UserType]:
        """List all active users."""
        repo = UserRepository(info.context.db)
        models = await repo.get_all_active()
        return [UserType.from_model(m) for m in models]
```

### src/app/graphql/mutations/user.py

```python
import strawberry
from strawberry.types import Info
from app.graphql.context import GraphQLContext
from app.graphql.types.user import CreateUserInput, UpdateUserInput, UserType
from app.repositories.user_repository import UserRepository
from app.core.security import hash_password


@strawberry.type
class UserMutation:

    @strawberry.mutation
    async def create_user(
        self,
        info: Info[GraphQLContext, None],
        input: CreateUserInput,
    ) -> UserType:
        repo = UserRepository(info.context.db)
        existing = await repo.get_by_email(input.email)
        if existing:
            raise ValueError(f"Email {input.email} is already registered")

        user = await repo.create(
            email=input.email,
            name=input.name,
            hashed_password=hash_password(input.password),
        )
        return UserType.from_model(user)

    @strawberry.mutation
    async def update_user(
        self,
        info: Info[GraphQLContext, None],
        id: int,
        input: UpdateUserInput,
    ) -> UserType:
        if not info.context.current_user:
            raise PermissionError("Authentication required")

        repo = UserRepository(info.context.db)
        user = await repo.update(id, input)
        if not user:
            raise ValueError(f"User {id} not found")
        return UserType.from_model(user)
```

### src/app/graphql/subscriptions/user.py

```python
import asyncio
from typing import AsyncGenerator
import strawberry
from strawberry.types import Info
from app.graphql.context import GraphQLContext
from app.graphql.types.user import UserType


@strawberry.type
class UserSubscription:

    @strawberry.subscription
    async def user_status_changed(
        self,
        info: Info[GraphQLContext, None],
    ) -> AsyncGenerator[UserType, None]:
        """Real-time user status updates — connect to Redis pub/sub in production."""
        for _ in range(10):
            await asyncio.sleep(1)
            if info.context.current_user:
                yield UserType.from_model(info.context.current_user)
```

### src/app/graphql/schema.py

```python
import strawberry
from strawberry.fastapi import GraphQLRouter
from app.graphql.queries.user import UserQuery
from app.graphql.mutations.user import UserMutation
from app.graphql.subscriptions.user import UserSubscription
from app.graphql.context import get_context


@strawberry.type
class Query(UserQuery):
    pass


@strawberry.type
class Mutation(UserMutation):
    pass


@strawberry.type
class Subscription(UserSubscription):
    pass


schema = strawberry.Schema(
    query=Query,
    mutation=Mutation,
    subscription=Subscription,
)

graphql_router = GraphQLRouter(
    schema,
    context_getter=get_context,
    graphql_ide="graphiql",     # swap to None in production
)
```

### src/app/main.py

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import get_settings
from app.graphql.schema import graphql_router

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(title=settings.PROJECT_NAME, lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(graphql_router, prefix="/graphql")


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
```

### tests/conftest.py

```python
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.main import app
from app.core.database import Base, get_db

TEST_DB_URL = "sqlite+aiosqlite:///:memory:"


@pytest_asyncio.fixture(scope="session")
async def engine():
    engine = create_async_engine(TEST_DB_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    await engine.dispose()


@pytest_asyncio.fixture
async def db_session(engine):
    Session = async_sessionmaker(engine, expire_on_commit=False)
    async with Session() as session:
        async with session.begin():
            yield session
            await session.rollback()


@pytest_asyncio.fixture
async def client(db_session):
    async def override_db():
        yield db_session

    app.dependency_overrides[get_db] = override_db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()
```

### tests/graphql/test_queries.py

```python
import pytest


CREATE_USER = """
mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    id
    email
    name
  }
}
"""

GET_USER = """
query GetUser($id: Int!) {
  user(id: $id) {
    id
    email
  }
}
"""


@pytest.mark.asyncio
async def test_create_user(client):
    response = await client.post("/graphql", json={
        "query": CREATE_USER,
        "variables": {
            "input": {"email": "test@example.com", "name": "Test", "password": "pass123"}
        },
    })
    assert response.status_code == 200
    data = response.json()
    assert "errors" not in data
    assert data["data"]["createUser"]["email"] == "test@example.com"


@pytest.mark.asyncio
async def test_get_nonexistent_user(client):
    response = await client.post("/graphql", json={
        "query": GET_USER,
        "variables": {"id": 9999},
    })
    assert response.status_code == 200
    assert response.json()["data"]["user"] is None
```

---

## Stack 2 — graphene-django

### Setup

```bash
uv init project-name
cd project-name
uv add django graphene-django django-environ psycopg[binary] gunicorn
uv add --dev pytest pytest-django ruff mypy django-stubs
django-admin startproject config .
python manage.py startapp users
```

### Project Structure

```
project-name/
├── pyproject.toml
├── manage.py
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── local.py
│   │   └── production.py
│   ├── urls.py
│   └── schema.py          # Root schema
├── users/
│   ├── models.py
│   ├── schema.py          # User types, queries, mutations
│   └── tests/
│       └── test_schema.py
└── tests/
    └── conftest.py
```

### config/settings/base.py (additions)

```python
INSTALLED_APPS += [
    "graphene_django",
    "users",
]

GRAPHENE = {
    "SCHEMA": "config.schema.schema",
    "MIDDLEWARE": [
        "graphql_jwt.middleware.JSONWebTokenMiddleware",
    ],
}
```

### users/schema.py

```python
import graphene
from graphene_django import DjangoObjectType
from graphene_django.filter import DjangoFilterConnectionField
from graphql_jwt.decorators import login_required
from .models import User


class UserType(DjangoObjectType):
    class Meta:
        model = User
        fields = ("id", "email", "name", "is_active", "date_joined")
        filter_fields = {"email": ["exact", "icontains"], "is_active": ["exact"]}
        interfaces = (graphene.relay.Node,)   # Relay pagination


class CreateUserMutation(graphene.Mutation):
    class Arguments:
        email = graphene.String(required=True)
        name = graphene.String(required=True)
        password = graphene.String(required=True)

    user = graphene.Field(UserType)

    def mutate(self, info, email, name, password):
        if User.objects.filter(email=email).exists():
            raise Exception("Email already registered")
        user = User.objects.create_user(email=email, username=email, password=password)
        user.name = name
        user.save()
        return CreateUserMutation(user=user)


class UserQuery(graphene.ObjectType):
    me = graphene.Field(UserType)
    user = graphene.relay.Node.Field(UserType)
    all_users = DjangoFilterConnectionField(UserType)

    @login_required
    def resolve_me(self, info):
        return info.context.user


class UserMutation(graphene.ObjectType):
    create_user = CreateUserMutation.Field()
```

### config/schema.py

```python
import graphene
import graphql_jwt
from users.schema import UserQuery, UserMutation


class Query(UserQuery, graphene.ObjectType):
    pass


class Mutation(UserMutation, graphene.ObjectType):
    token_auth = graphql_jwt.ObtainJSONWebToken.Field()
    verify_token = graphql_jwt.Verify.Field()
    refresh_token = graphql_jwt.Refresh.Field()


schema = graphene.Schema(query=Query, mutation=Mutation)
```

### config/urls.py (additions)

```python
from django.views.decorators.csrf import csrf_exempt
from graphene_django.views import GraphQLView

urlpatterns += [
    path("graphql/", csrf_exempt(GraphQLView.as_view(graphiql=True))),
]
```

### users/tests/test_schema.py

```python
import pytest
from graphene_django.utils.testing import graphql_query


@pytest.fixture
def client_query(client):
    def func(*args, **kwargs):
        return graphql_query(*args, **kwargs, client=client)
    return func


@pytest.mark.django_db
def test_create_user(client_query):
    response = client_query(
        """
        mutation {
          createUser(email: "test@example.com", name: "Test", password: "pass") {
            user { id email }
          }
        }
        """
    )
    assert response.status_code == 200
    content = response.json()
    assert "errors" not in content
    assert content["data"]["createUser"]["user"]["email"] == "test@example.com"
```

---

## Stack 3 — Ariadne + FastAPI (schema-first)

### Project Structure

```
project-name/
├── pyproject.toml
├── src/
│   └── app/
│       ├── main.py
│       ├── config.py
│       ├── graphql/
│       │   ├── schema.py         # Loads SDL + binds resolvers
│       │   ├── resolvers/
│       │   │   ├── query.py
│       │   │   └── mutation.py
│       │   └── scalars.py
│       └── schema/
│           ├── types.graphql     # SDL type definitions
│           ├── query.graphql     # Query operations
│           └── mutation.graphql  # Mutation operations
```

### schema/types.graphql

```graphql
scalar DateTime

type User {
  id: ID!
  email: String!
  name: String!
  isActive: Boolean!
  createdAt: DateTime!
}

input CreateUserInput {
  email: String!
  name: String!
  password: String!
}
```

### schema/query.graphql

```graphql
type Query {
  me: User
  user(id: ID!): User
  users: [User!]!
}
```

### schema/mutation.graphql

```graphql
type Mutation {
  createUser(input: CreateUserInput!): User!
  login(email: String!, password: String!): String!   # returns JWT
}
```

### src/app/graphql/schema.py

```python
from pathlib import Path
from ariadne import load_schema_from_path, make_executable_schema, QueryType, MutationType
from app.graphql.resolvers.query import query
from app.graphql.resolvers.mutation import mutation
from app.graphql.scalars import datetime_scalar

SCHEMA_DIR = Path(__file__).parent.parent.parent / "schema"

type_defs = load_schema_from_path(str(SCHEMA_DIR))

schema = make_executable_schema(
    type_defs,
    query,
    mutation,
    datetime_scalar,
)
```

### src/app/graphql/resolvers/query.py

```python
from ariadne import QueryType
from sqlalchemy.ext.asyncio import AsyncSession

query = QueryType()


@query.field("me")
async def resolve_me(_, info):
    return info.context["current_user"]


@query.field("user")
async def resolve_user(_, info, id: str):
    db: AsyncSession = info.context["db"]
    # load and return user
```

### src/app/main.py

```python
from fastapi import FastAPI, Request
from ariadne.asgi import GraphQL
from app.graphql.schema import schema
from app.core.database import get_db


async def get_context(request: Request) -> dict:
    db = await anext(get_db())
    return {"request": request, "db": db}


app = FastAPI()
graphql_app = GraphQL(schema, context_value=get_context, debug=True)
app.mount("/graphql", graphql_app)
```

---

## Output Format

1. **Stack choice confirmation** — explain why the chosen stack fits the requirements
2. **`uv init` + install commands** — exact commands to bootstrap the project
3. **Complete project structure** — directory tree
4. **All generated files** — full content, one block per file with path as heading
5. **Migration command** — if Alembic or Django migrations are needed
6. **Run commands** — how to start the dev server and run tests

Always generate a working example with at least one type (User or the entity the user mentioned). Do not generate empty placeholders — every file must have real, runnable code.
