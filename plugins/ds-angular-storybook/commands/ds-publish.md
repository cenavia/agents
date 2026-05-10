---
description: >
  Prepare and publish an Angular Design System as an npm package (public or private registry). Use when
  the DS is ready for distribution to other projects or repositories — configures ng-packagr, semver
  versioning, package.json peer dependencies, .npmrc for private registry, and GitHub Actions CI/CD
  pipeline. Also use when bumping the DS version for a new release.
---

# Publish Design System as npm Package

Prepare and publish the Angular DS library to an npm registry (public or private).

## Input

Publish target and version bump: $ARGUMENTS

Examples:
- `/ds-publish` — interactive: asks registry, version bump type
- `/ds-publish patch` — bump patch version and publish to configured registry
- `/ds-publish minor --registry https://npm.pkg.github.com` — minor bump to GitHub Packages
- `/ds-publish major --dry-run` — show what would be published without publishing

---

## Step 1 — Pre-publish checklist

Run these checks and stop if any fail:

```bash
# 1. Build succeeds
npx ng build [ds-name] --configuration production
[ $? -ne 0 ] && echo "❌ Build failed. Fix errors before publishing." && exit 1

# 2. Tests pass
npx jest --ci --coverage --runInBand
[ $? -ne 0 ] && echo "❌ Tests failed. Fix failing tests before publishing." && exit 1

# 3. Storybook builds
npm run build:storybook
[ $? -ne 0 ] && echo "❌ Storybook build failed." && exit 1

echo "✅ All checks passed."
```

---

## Step 2 — Read references

Read `skills/angular-design-system-storybook/references/strategy-3-npm.md` for complete npm publishing configuration.

---

## Step 3 — Configure ng-packagr

Verify `projects/[ds-name]/ng-package.json` is correct:

```json
{
  "$schema": "../../node_modules/ng-packagr/ng-package.schema.json",
  "lib": {
    "entryFile": "src/public-api.ts",
    "cssUrl": "inline"
  },
  "deleteDestPath": false
}
```

Verify `projects/[ds-name]/package.json` is publishable:

```json
{
  "name": "@[scope]/[ds-name]",
  "version": "[current-version]",
  "peerDependencies": {
    "@angular/common": ">=17.0.0",
    "@angular/core": ">=17.0.0"
  },
  "exports": {
    ".": {
      "types": "./index.d.ts",
      "esm2022": "./esm2022/index.mjs",
      "default": "./fesm2022/[ds-name].mjs"
    }
  },
  "sideEffects": [
    "**/*.scss",
    "**/tokens/**"
  ]
}
```

---

## Step 4 — Version bump

Determine the version bump type from `$ARGUMENTS` or ask the user:
- `patch` — bug fixes, non-breaking token additions (1.0.0 → 1.0.1)
- `minor` — new components or tokens, backwards compatible (1.0.0 → 1.1.0)
- `major` — breaking changes: token renames, removed components, API changes (1.0.0 → 2.0.0)

```bash
# Read current version
CURRENT=$(cat projects/[ds-name]/package.json | python3 -c "import sys,json; print(json.load(sys.stdin)['version'])")
echo "Current version: $CURRENT"

# Bump version in library package.json
npm version [patch|minor|major] --prefix projects/[ds-name] --no-git-tag-version

# Sync version to root package.json if needed
NEW_VERSION=$(cat projects/[ds-name]/package.json | python3 -c "import sys,json; print(json.load(sys.stdin)['version'])")
echo "New version: $NEW_VERSION"
```

---

## Step 5 — Update CHANGELOG

Create or update `CHANGELOG.md` at the project root with a new entry:

```markdown
## [version] — [YYYY-MM-DD]

### Added
- [New component or feature]

### Changed
- [Modified behavior]

### Fixed
- [Bug fix]

### Breaking Changes (major only)
- [Breaking change description and migration guide]
```

---

## Step 6 — Configure registry

### Public npm registry (default)

```bash
# In projects/[ds-name]/.npmrc (if scoped)
@[scope]:registry=https://registry.npmjs.org/
```

### GitHub Packages (private)

```bash
# In projects/[ds-name]/.npmrc
@[scope]:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

### Verdaccio / Nexus (enterprise)

```bash
@[scope]:registry=[registry-url]
//[registry-host]/:_authToken=${NODE_AUTH_TOKEN}
```

Ask the user which registry to use if not specified in `$ARGUMENTS`.

---

## Step 7 — Build and publish

```bash
# Build the library for production
npx ng build [ds-name] --configuration production

# Navigate to dist
cd dist/[ds-name]

# Dry run first (always)
npm publish --dry-run

# If dry run looks correct, ask user to confirm
echo "About to publish @[scope]/[ds-name]@${NEW_VERSION} to [registry]."
echo "Proceed? (user must confirm in chat)"
```

**STOP HERE** — Do not run `npm publish` without explicit user confirmation in chat.

After confirmation:

```bash
cd dist/[ds-name]
npm publish [--access public] [--tag beta]
```

---

## Step 8 — GitHub Actions CI/CD pipeline

Create `.github/workflows/publish-ds.yml`:

```yaml
name: Publish Design System

on:
  push:
    tags:
      - 'ds-v*'

jobs:
  build-and-publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://npm.pkg.github.com'   # or npmjs.org

      - run: npm ci

      - name: Run tests
        run: npm run test:ci

      - name: Build library
        run: npm run build:ds

      - name: Publish to registry
        run: npm publish
        working-directory: dist/[ds-name]
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NODE_AUTH_TOKEN }}

  chromatic:
    needs: build-and-publish
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - run: npm ci
      - uses: chromaui/action@latest
        with:
          projectToken: ${{ secrets.CHROMATIC_PROJECT_TOKEN }}
          buildScriptName: build:storybook
```

---

## Step 9 — Tag and push (optional)

If the user wants a git tag:

```bash
git add projects/[ds-name]/package.json CHANGELOG.md
git commit -m "chore: release ds-v${NEW_VERSION}"
git tag "ds-v${NEW_VERSION}"
```

**STOP** — confirm with the user before `git push` or `git push --tags`.

---

## Step 10 — Report

```
✅ Published @[scope]/[ds-name]@[version] to [registry]

Install in consumer projects:
  npm install @[scope]/[ds-name]@[version]

Import in Angular:
  import { DsButtonComponent } from '@[scope]/[ds-name]';

Import tokens in styles.scss:
  @use '@[scope]/[ds-name]/tokens' as *;

Next steps:
  - Add GitHub Packages secret NODE_AUTH_TOKEN for CI
  - Set CHROMATIC_PROJECT_TOKEN for visual testing
  - Update consumer projects to new version
```
