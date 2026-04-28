# New Angular Feature

Scaffold a complete Angular feature from a single description.

## What to build

Feature description: $ARGUMENTS

## Steps to follow

1. **Read context first**: Check `package.json` for the Angular version. Check if the project uses standalone components or NgModules.

2. **Plan the feature structure**:
   ```
   src/app/features/<feature-name>/
   ├── <feature-name>.routes.ts      ← lazy route definition
   ├── pages/
   │   └── <feature-name>-page/
   │       ├── <feature-name>-page.component.ts
   │       ├── <feature-name>-page.component.html
   │       └── <feature-name>-page.component.scss
   ├── components/                   ← presentational components
   └── services/
       └── <feature-name>.service.ts
   ```

3. **Generate with CLI** (always use CLI, then augment):
   ```bash
   npx ng generate component features/<name>/pages/<name>-page --standalone
   npx ng generate service features/<name>/services/<name>
   ```

4. **Wire lazy route** into the parent router (usually `app.routes.ts`):
   ```ts
   {
     path: '<name>',
     loadChildren: () => import('./features/<name>/<name>.routes').then(m => m.<NAME>_ROUTES)
   }
   ```

5. **Apply signal patterns**:
   - Local state → `signal()`
   - Derived state → `computed()`
   - Async data → `resource()` (v19+) or `rxResource()`
   - Use `inject()` for all dependencies

6. **Run `npx ng build`** and fix any errors before reporting done.

7. Report: file list created, route path, and next suggested steps.
