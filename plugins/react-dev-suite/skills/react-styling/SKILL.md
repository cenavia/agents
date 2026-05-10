---
name: react-styling
description: |
  Styling React applications with JS and TS. Covers Tailwind CSS (utility classes,
  responsive design, dark mode, custom theme, shadcn/ui design system), Material UI
  (sx prop, styled(), createTheme, ThemeProvider, colorSchemes, cssVariables, dark
  mode, TypeScript theme augmentation), and MUI + Tailwind CSS v4 integration
  (cascade layers, enableCssLayer). Guidance on choosing the right approach and
  combining systems.

  USE WHEN: user mentions "Tailwind", "tailwindcss", "utility classes", "dark mode",
  "responsive design", "Material UI", "MUI", "sx prop", "styled()", "createTheme",
  "ThemeProvider", "shadcn/ui", "design tokens", "tailwind design system",
  "MUI Tailwind", "component styling", "CSS variables", "theme customization",
  asks about "styling approach", "CSS-in-JS vs utility"

  DO NOT USE FOR: animation libraries — use dedicated skills,
  component logic — use react-dev-suite:react-core
allowed-tools: Read, Grep, Glob, Write, Edit
---

# React Styling — Tailwind CSS & Material UI

---

## Tailwind CSS

```bash
npm install tailwindcss @tailwindcss/vite
```

```ts
// vite.config.ts
import tailwindcss from '@tailwindcss/vite';
export default { plugins: [tailwindcss()] };

// index.css
@import "tailwindcss";
```

### Core Utility Patterns

```tsx
// Layout — flexbox & grid
<div className="flex items-center justify-between gap-4">
  <div className="grid grid-cols-3 gap-6 w-full">
    <Card className="col-span-2" />
  </div>
</div>

// Responsive — mobile-first
<div className="text-sm md:text-base lg:text-lg
                flex flex-col md:flex-row
                p-4 md:p-6 lg:p-8">

// Dark mode
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100">

// State variants
<button className="bg-blue-600 hover:bg-blue-700 active:bg-blue-800
                   disabled:opacity-50 disabled:cursor-not-allowed
                   focus-visible:ring-2 focus-visible:ring-blue-500
                   transition-colors duration-200">
  Submit
</button>
```

### Custom Theme (Tailwind v4)

```css
/* index.css */
@import "tailwindcss";

@theme {
  --color-primary-50:  #eff6ff;
  --color-primary-500: #3b82f6;
  --color-primary-900: #1e3a5f;
  --font-sans: 'Inter', sans-serif;
  --radius-card: 0.75rem;
  --shadow-card: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}
```

```tsx
// Use custom tokens
<div className="bg-primary-500 text-white rounded-card shadow-card font-sans">
```

### Component Composition with `cn()`

```bash
npm install clsx tailwind-merge
```

```ts
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

```tsx
// Reusable component with variant styles
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
}

function Button({ variant = 'primary', size = 'md', className, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center font-medium rounded-md transition-colors',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
        {
          'bg-blue-600 text-white hover:bg-blue-700':        variant === 'primary',
          'bg-gray-100 text-gray-900 hover:bg-gray-200':    variant === 'secondary',
          'bg-transparent text-gray-600 hover:bg-gray-100': variant === 'ghost',
          'text-xs px-2.5 py-1.5': size === 'sm',
          'text-sm px-4 py-2':     size === 'md',
          'text-base px-6 py-3':   size === 'lg',
        },
        className
      )}
      {...props}
    />
  );
}
```

### Design System with shadcn/ui

```bash
npx shadcn@latest init
npx shadcn@latest add button card dialog
```

```tsx
// shadcn/ui components are in src/components/ui/
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

function ProductCard({ product }: { product: Product }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{product.name}</CardTitle>
      </CardHeader>
      <CardContent>
        <p>{product.description}</p>
        <Button variant="default" size="sm">Add to Cart</Button>
      </CardContent>
    </Card>
  );
}
```

---

## Material UI

```bash
npm install @mui/material @emotion/react @emotion/styled
```

### sx Prop — Inline Styles with Theme Access

```tsx
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';

<Box
  sx={{
    display: 'flex',
    gap: 2,              // theme.spacing(2) = 16px
    p: { xs: 1, md: 3 },  // responsive spacing
    bgcolor: 'background.paper',
    borderRadius: 2,
    border: 1,
    borderColor: 'divider',
    '&:hover': { boxShadow: 4 },
  }}
>
  <Typography variant="h6" color="text.primary">Title</Typography>
</Box>
```

### styled() — Reusable Styled Components

```tsx
import { styled } from '@mui/material/styles';

const StyledCard = styled(Box)(({ theme }) => ({
  padding: theme.spacing(3),
  borderRadius: theme.shape.borderRadius * 2,
  backgroundColor: theme.palette.background.paper,
  boxShadow: theme.shadows[2],
  [theme.breakpoints.down('sm')]: {
    padding: theme.spacing(2),
  },
}));

// With custom props
interface ChipProps { active?: boolean; }
const FilterChip = styled('button')<ChipProps>(({ theme, active }) => ({
  backgroundColor: active ? theme.palette.primary.main : theme.palette.grey[200],
  color:           active ? theme.palette.primary.contrastText : theme.palette.text.primary,
}));
```

### Custom Theme with CSS Variables + Dark Mode

```tsx
import { createTheme, ThemeProvider, CssBaseline } from '@mui/material';

const theme = createTheme({
  cssVariables: {
    colorSchemeSelector: 'class',  // or 'data-mui-color-scheme'
  },
  colorSchemes: {
    light: {
      palette: {
        primary:    { main: '#1976d2' },
        background: { default: '#f5f5f5', paper: '#ffffff' },
      },
    },
    dark: {
      palette: {
        primary:    { main: '#90caf9' },
        background: { default: '#121212', paper: '#1e1e1e' },
      },
    },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", sans-serif',
    h1: { fontSize: '2.5rem', fontWeight: 700 },
  },
  shape: { borderRadius: 8 },
});

function App() {
  return (
    <ThemeProvider theme={theme} defaultMode="system">
      <CssBaseline enableColorScheme />
      <Router />
    </ThemeProvider>
  );
}

// Toggle dark mode in a component
import { useColorScheme } from '@mui/material';

function ThemeToggle() {
  const { mode, setMode } = useColorScheme();
  return (
    <button onClick={() => setMode(mode === 'light' ? 'dark' : 'light')}>
      {mode === 'light' ? '🌙' : '☀️'}
    </button>
  );
}
```

### TypeScript Theme Augmentation

```ts
// types/mui.d.ts
import '@mui/material/styles';

declare module '@mui/material/styles' {
  interface Palette {
    brand: {
      main: string;
      light: string;
      dark: string;
    };
  }
  interface PaletteOptions {
    brand?: {
      main: string;
      light: string;
      dark: string;
    };
  }
}
```

---

## MUI + Tailwind CSS v4 Integration

```ts
// vite.config.ts — enable CSS layer for compatibility
import tailwindcss from '@tailwindcss/vite';

export default { plugins: [tailwindcss()] };
```

```css
/* index.css */
@import "tailwindcss";
@layer theme, base, mui, components, utilities;
```

```tsx
// ThemeProvider with CSS layer enabled
import { createTheme } from '@mui/material/styles';

const theme = createTheme({ cssVariables: true });

// Now MUI styles go into @layer mui — Tailwind utilities win by default
<Box sx={{ p: 2 }} className="rounded-xl shadow-lg">
  Mixed MUI sx + Tailwind classes
</Box>
```

---

## Styling Approach Decision

| Scenario | Recommended Approach |
|---|---|
| New greenfield project | Tailwind CSS + shadcn/ui |
| Enterprise design system | Material UI with custom theme |
| Mixed team (design + dev) | Tailwind + design tokens |
| Existing MUI project | `sx` prop + `styled()` for complex overrides |
| MUI + Tailwind existing | Use cascade layers integration |

---

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| Inline style `style={{ margin: 8 }}` instead of `sx` | Use `sx={{ m: 1 }}` — theme-aware |
| Tailwind class string concatenation without `cn()` | Use `cn()` — avoids conflicting utilities |
| Re-creating theme object inside component | Move theme outside component or `useMemo` |
| Overriding MUI with `!important` | Use `sx`, `styled()`, or theme `components` overrides |
| Not using `CssBaseline` with MUI | Add `CssBaseline` — normalizes browser styles |
