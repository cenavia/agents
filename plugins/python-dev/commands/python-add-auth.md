# Add Authentication & Authorization

You are a Python security expert. Add a complete authentication and authorization system to an existing FastAPI or Django project. Generate only the auth layer — do not modify existing business logic.

## Context

The user has a working FastAPI or Django API and needs to add auth. Generate the minimum necessary files: security utilities, dependencies/middleware, auth endpoints, and user model extensions. The result must be drop-in compatible with an existing project structure.

## Requirements

$ARGUMENTS

## Instructions

### 1. Detect Framework and Auth Type

**Framework:**
- FastAPI → JWT with OAuth2PasswordBearer
- Django → Django REST Framework + SimpleJWT, or session auth

**Auth type from user input:**
- `jwt` — stateless JWT access + refresh tokens (default)
- `oauth2` — social login via OAuth2 provider (Google, GitHub)
- `api-key` — simple API key header auth
- `session` — Django session-based auth

### 2. FastAPI — JWT Auth

**Install dependencies:**

```bash
uv add pyjwt[crypto] passlib[bcrypt] python-multipart
```

**core/security.py:**

```python
from datetime import datetime, timedelta, timezone
from typing import Any

import jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

ALGORITHM = "HS256"


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def create_access_token(subject: Any, expires_delta: timedelta | None = None) -> str:
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    payload = {"sub": str(subject), "exp": expire, "type": "access"}
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(subject: Any) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    payload = {"sub": str(subject), "exp": expire, "type": "refresh"}
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str) -> dict:
    return jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
```

**api/deps.py (auth dependency):**

```python
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import decode_token
from app.repositories.user_repository import user_repository

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    credentials_exc = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_token(token)
        if payload.get("type") != "access":
            raise credentials_exc
        user_id = int(payload["sub"])
    except Exception:
        raise credentials_exc

    user = await user_repository.get(db, user_id)
    if not user:
        raise credentials_exc
    return user


async def get_current_active_user(
    current_user=Depends(get_current_user),
):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user


def require_role(*roles: str):
    async def _check(user=Depends(get_current_active_user)):
        if user.role not in roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return user
    return _check
```

**api/v1/endpoints/auth.py:**

```python
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    verify_password,
)
from app.repositories.user_repository import user_repository
from app.schemas.auth import Token, TokenRefresh

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=Token)
async def login(
    form: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    user = await user_repository.get_by_email(db, form.username)
    if not user or not verify_password(form.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return {
        "access_token": create_access_token(user.id),
        "refresh_token": create_refresh_token(user.id),
        "token_type": "bearer",
    }


@router.post("/refresh", response_model=Token)
async def refresh_token(body: TokenRefresh, db: Annotated[AsyncSession, Depends(get_db)]):
    try:
        payload = decode_token(body.refresh_token)
        if payload.get("type") != "refresh":
            raise ValueError
        user_id = int(payload["sub"])
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    user = await user_repository.get(db, user_id)
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    return {
        "access_token": create_access_token(user.id),
        "refresh_token": create_refresh_token(user.id),
        "token_type": "bearer",
    }
```

**schemas/auth.py:**

```python
from pydantic import BaseModel


class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenRefresh(BaseModel):
    refresh_token: str
```

**Add to config.py:**

```python
SECRET_KEY: str
ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
REFRESH_TOKEN_EXPIRE_DAYS: int = 7
```

### 3. FastAPI — API Key Auth (simpler alternative)

```python
# api/deps.py — API key variant
from fastapi import Security, HTTPException, status
from fastapi.security import APIKeyHeader

API_KEY_HEADER = APIKeyHeader(name="X-API-Key", auto_error=False)


async def get_api_key(api_key: str = Security(API_KEY_HEADER)):
    if not api_key or not await validate_api_key(api_key):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid or missing API key",
        )
    return api_key
```

### 4. Django — SimpleJWT

**Install:**

```bash
uv add djangorestframework-simplejwt
```

**settings/base.py additions:**

```python
INSTALLED_APPS += ["rest_framework", "rest_framework_simplejwt"]

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
}

from datetime import timedelta
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=30),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
}
```

**urls.py additions:**

```python
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns += [
    path("api/auth/login/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]
```

### 5. Add Settings Variables to .env.example

```env
# Auth
SECRET_KEY=your-256-bit-secret-key-here
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
```

Generate a secure SECRET_KEY suggestion:

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

## Output Format

1. **`core/security.py`** — hash, verify, create/decode tokens
2. **`api/deps.py`** — `get_current_user`, `get_current_active_user`, `require_role`
3. **`api/v1/endpoints/auth.py`** — login and refresh endpoints
4. **`schemas/auth.py`** — Token and TokenRefresh schemas
5. **Settings additions** — fields to add to config.py and .env.example
6. **`uv add` command** — with exact packages for the chosen auth type
7. **Router registration** — one-liner to add to main router

Do not generate a full user model or database migration — assume the user model already exists. Only add `hashed_password`, `is_active`, and `role` fields if they are missing.
