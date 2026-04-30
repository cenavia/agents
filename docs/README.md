# Plugin Hub para Claude Code

Sistema de gestión de plugins para Claude Code. Permite instalar, eliminar y listar plugins de forma precisa usando un registro local como fuente de verdad.

---

## Gestión de plugins — `plugin.sh`

### Comandos

```bash
./plugin.sh list                    # Ver plugins disponibles y estado instalado
./plugin.sh install <nombre>        # Instalar un plugin
./plugin.sh install --all           # Instalar todos los plugins
./plugin.sh remove  <nombre>        # Eliminar un plugin
./plugin.sh remove  --all           # Eliminar todos los plugins instalados
```

### Flag `--dry-run`

Muestra exactamente qué haría el comando sin ejecutar ningún cambio. Funciona con `install` y `remove`.

```bash
./plugin.sh install ai-dev --dry-run
./plugin.sh remove  plan   --dry-run
```

### `list` — estado del sistema

Muestra todos los plugins disponibles en `agents/plugins/`, con indicador de instalado/no instalado y la diferencia entre lo que tiene el plugin fuente y lo que está activo en `.claude/`.

```
● ai-dev  v1.1.0  [instalado]
  fuente  — commands: 7  skills: 11  agents: 6
  activos — commands: 7  skills: 11  agents: 6

○ ng-kit  v1.2.0
  commands: 6  skills: 2  agents: 3
```


### Registro de instalación

Cada `install` escribe una entrada en `.claude/.plugins-registry.json`. El `remove` lee ese registro para saber exactamente qué archivos pertenecen a cada plugin, sin adivinar por rutas ni nombres de carpeta.

```json
{
  "ai-dev": {
    "commands": "commands/ai-dev",
    "skills":   ["rag", "embeddings", "langgraph-core", "..."],
    "agents":   ["ai-engineer.md", "rag-engineer.md", "..."]
  },
  "plan": {
    "commands": "commands/plan",
    "skills":   ["breakdown-feature-prd", "project-manager", "..."],
    "agents":   ["business-analyst.md", "tech-lead.md", "..."]
  }
}
```

### Detección de conflictos

Si dos plugins incluyen un skill o agent con el mismo nombre, el segundo recibe una advertencia y lo omite. El primero en instalarse es el dueño registrado.

```
! skill angular-new-app ya instalado por 'plan' — omitido
```

Esto evita que un plugin pise silenciosamente los archivos de otro.

### Migración automática de symlinks legacy

Si el proyecto tenía symlinks de una instalación anterior, el script los convierte automáticamente a copias reales y reconstruye el registro antes de continuar. No requiere ninguna acción manual.

---

## Estructura de `.claude/`

```
.claude/
├── commands/
│   └── <plugin>/          ← un namespace por plugin → /<plugin>:<comando>
├── skills/
│   └── <skill>/           ← una carpeta por skill (copia real)
├── agents/
│   └── <agent>.md         ← un archivo por agent (copia real)
└── .plugins-registry.json ← fuente de verdad: qué instaló cada plugin
```

Claude Code carga automáticamente lo que hay en cada carpeta al iniciar sesión.

