# Referencia: Estrategia 3 — Paquete npm privado

## Cuándo usar esta estrategia
- Múltiples repositorios consumen el mismo Design System
- Se necesita versionado semántico independiente (SemVer)
- Equipos grandes / empresas con varias apps

---

## Registros privados disponibles

| Registro        | Cuándo usarlo                      | Precio            |
|-----------------|-------------------------------------|-------------------|
| GitHub Packages | Equipos en GitHub                   | Gratis hasta 500MB|
| GitLab Registry | Equipos en GitLab                   | Incluido en plan  |
| npm Org privada | Empresas con múltiples paquetes     | $7/mes por usuario|
| Verdaccio       | On-premise, sin costo externo       | Gratuito (self)   |
| AWS CodeArtifact| Infraestructura en AWS              | Pay per use       |

---

## Preparar la librería

### `ng-package.json`

```json
{
  "$schema": "../../node_modules/ng-packagr/ng-package.schema.json",
  "lib": {
    "entryFile": "src/public-api.ts",
    "cssUrl": "inline"
  },
  "dest": "../../dist/mi-design-system"
}
```

### `package.json` de la librería

```json
{
  "name": "@mi-empresa/design-system",
  "version": "1.0.0",
  "description": "Design System oficial de Mi Empresa",
  "license": "UNLICENSED",
  "peerDependencies": {
    "@angular/common": ">=17.0.0",
    "@angular/core": ">=17.0.0"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/mi-empresa/design-system"
  }
}
```

---

## Opción A — GitHub Packages

### 1. Crear Personal Access Token

GitHub → Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
Permisos necesarios: `write:packages`, `read:packages`

### 2. Autenticarse

```bash
npm login --registry=https://npm.pkg.github.com --scope=@mi-empresa
```

O configurar `~/.npmrc`:

```
//npm.pkg.github.com/:_authToken=TU_TOKEN
@mi-empresa:registry=https://npm.pkg.github.com
```

### 3. `.npmrc` en la raíz del proyecto

```
@mi-empresa:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NPM_TOKEN}
```

### 4. Compilar y publicar

```bash
ng build mi-design-system
cd dist/mi-design-system
npm publish
```

---

## Opción B — Verdaccio (on-premise)

### `docker-compose.yml`

```yaml
version: '3.8'
services:
  verdaccio:
    image: verdaccio/verdaccio:5
    container_name: verdaccio
    ports:
      - "4873:4873"
    volumes:
      - ./verdaccio/storage:/verdaccio/storage
      - ./verdaccio/config:/verdaccio/conf
    environment:
      - VERDACCIO_PORT=4873
```

```bash
docker-compose up -d

# Configurar cliente
npm set @mi-empresa:registry http://localhost:4873

# Crear usuario
npm adduser --registry http://localhost:4873

# Publicar
cd dist/mi-design-system
npm publish --registry http://localhost:4873
```

---

## Versionado semántico

```bash
npm version patch   # bugfix:    1.0.0 → 1.0.1
npm version minor   # feature:   1.0.0 → 1.1.0
npm version major   # breaking:  1.0.0 → 2.0.0
```

| Cambio                               | Versión  |
|--------------------------------------|----------|
| Bugfix sin cambio de API             | PATCH    |
| Nuevo componente / nueva prop        | MINOR    |
| Renombrar prop / cambiar selector    | MAJOR    |

---

## GitHub Actions — CI/CD completo

```yaml
# .github/workflows/publish.yml
name: Build & Publish Design System

on:
  push:
    branches: [main]
    paths:
      - 'projects/mi-design-system/**'

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://npm.pkg.github.com'
          scope: '@mi-empresa'

      - run: npm ci

      - name: Run tests
        run: npm run test:ci

      - name: Build library
        run: npm run build:ds

      - name: Publish
        run: cd dist/mi-design-system && npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## GitHub Actions — CI en Pull Requests

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:ci
      - uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/lcov.info
          flags: design-system
      - run: npm run build:ds
      - run: npm run build:storybook
```

---

## Instalar el paquete en un proyecto consumidor

```bash
# Configurar el scope (una vez por proyecto)
npm set @mi-empresa:registry https://npm.pkg.github.com

# Instalar
npm install @mi-empresa/design-system
```

```typescript
// En cualquier componente del proyecto consumidor
import { ButtonComponent, CardComponent } from '@mi-empresa/design-system';
```
