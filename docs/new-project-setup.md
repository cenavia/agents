# Guía: configurar plugins en un proyecto nuevo

Cómo llevar el sistema de gestión de plugins a un proyecto vacío desde cero.

---

## Requisitos previos

- `plugin.sh` disponible (incluido en este directorio o en el hub cenavia)
- Python 3 instalado (lo usa el registro internamente)
- Los plugins que querés instalar disponibles en `agents/plugins/`

---

## Estructura mínima necesaria

`plugin.sh` deriva todas sus rutas desde su propia ubicación (`SCRIPT_DIR`).
El proyecto debe tener esta estructura para que funcione:

```
mi-proyecto/
├── plugin.sh              ← el script de gestión
└── agents/
    └── plugins/
        └── <nombre>/      ← uno o más plugins
            ├── .claude-plugin/
            │   └── plugin.json
            ├── commands/
            ├── skills/
            ├── agents/
            └── README.md
```

Al ejecutar `install`, el script crea `.claude/` automáticamente.

---

## Flujo paso a paso

### 1. Crear el proyecto

```bash
mkdir mi-proyecto && cd mi-proyecto
```

### 2. Copiar `plugin.sh`

```bash
cp /ruta/a/cenavia/agents/docs/plugin.sh .
chmod +x plugin.sh
```

### 3. Agregar plugins

Elegir una de las dos opciones según el caso de uso:

**Opción A — Copia directa** (proyecto independiente de cenavia):

```bash
mkdir -p agents/plugins

# Un plugin específico
cp -r /ruta/a/cenavia/agents/plugins/plan agents/plugins/

# O todos los plugins de una vez
cp -r /ruta/a/cenavia/agents/plugins/. agents/plugins/
```

Usar cuando el proyecto no debe cambiar si cenavia evoluciona.

**Opción B — Symlink al hub** (siempre sincronizado con cenavia):

```bash
mkdir -p agents
ln -s /ruta/a/cenavia/agents/plugins agents/plugins
```

Usar cuando el proyecto siempre debe reflejar los plugins más recientes del hub.

### 4. Instalar

```bash
# Todos los plugins disponibles
./plugin.sh install --all

# O seleccionar los que necesitás
./plugin.sh install plan
./plugin.sh install ai-dev
```

### 5. Verificar

```bash
./plugin.sh list
```

La salida debe mostrar cada plugin con `[instalado]` y los conteos de commands, skills y agents activos.

---

## Resultado esperado

Después del install, `.claude/` queda así:

```
mi-proyecto/
├── plugin.sh
├── agents/
│   └── plugins/
│       └── plan/
└── .claude/
    ├── commands/
    │   └── plan/          ← slash commands del plugin
    ├── skills/            ← skills copiados (carpetas reales)
    ├── agents/            ← agents copiados (archivos .md)
    └── .plugins-registry.json   ← registro de qué instaló cada plugin
```

Claude Code carga lo que hay en `.claude/` al abrir el proyecto.

---

## Gestión posterior

```bash
# Ver estado en cualquier momento
./plugin.sh list

# Agregar un plugin nuevo
cp -r /ruta/a/cenavia/agents/plugins/ng-kit agents/plugins/
./plugin.sh install ng-kit

# Eliminar un plugin (solo borra sus archivos, no toca otros plugins)
./plugin.sh remove ng-kit

# Previsualizar sin ejecutar
./plugin.sh remove ng-kit --dry-run
./plugin.sh install ng-kit --dry-run
```

---

## Decisión: copia vs symlink

| Criterio | Copia (Opción A) | Symlink (Opción B) |
|----------|-----------------|-------------------|
| Independencia del hub | Sí — funciona sin cenavia | No — necesita cenavia en la misma máquina |
| Actualizaciones automáticas | No — hay que copiar de nuevo | Sí — refleja cambios del hub al instante |
| Portabilidad (otro equipo, CI) | Sí | Solo si el hub está en la misma ruta |
| Plugins parciales (no todos) | Sí, con copia selectiva | No, hereda todos los del hub |

---

## Archivos de referencia

| Archivo | Descripción |
|---------|-------------|
| `plugin.sh` | Script de gestión (este directorio) |
| `README.md` | Documentación del sistema de gestión |
| `plugin-install-guide.md` | Guía de instalación manual paso a paso |
