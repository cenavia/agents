#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# plugin.sh — Gestor de plugins para Claude Code
#
# Uso:
#   ./plugin.sh list
#   ./plugin.sh install <nombre>
#   ./plugin.sh install --all
#   ./plugin.sh remove  <nombre>
#   ./plugin.sh remove  --all
#
# Flags:
#   --dry-run   Muestra lo que haría sin ejecutar cambios
#
# Registro:
#   .claude/.plugins-registry.json — fuente de verdad de qué instaló cada plugin.
#   Permite eliminar skills y agents de forma precisa sin adivinar por rutas.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$SCRIPT_DIR/agents/plugins"
CLAUDE_DIR="$SCRIPT_DIR/.claude"
REGISTRY="$CLAUDE_DIR/.plugins-registry.json"

# ── Colores ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

DRY_RUN=""

# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────
log_ok()      { echo -e "  ${GREEN}+${RESET} $*"; }
log_skip()    { echo -e "  ${YELLOW}~${RESET} $*"; }
log_remove()  { echo -e "  ${RED}-${RESET} $*"; }
log_warn()    { echo -e "  ${YELLOW}!${RESET} $*"; }
log_dry()     { echo -e "  ${DIM}[dry]${RESET} $*"; }
log_info()    { echo -e "  ${BLUE}•${RESET} $*"; }
log_error()   { echo -e "${RED}ERROR:${RESET} $*" >&2; }
log_section() { echo -e "\n${BOLD}$*${RESET}"; }

# ─────────────────────────────────────────────────────────────────────────────
# Registro — .claude/.plugins-registry.json
#
# Formato:
# {
#   "plan": {
#     "commands": "commands/plan",
#     "skills":   ["breakdown-feature-prd", "product-ideation-brainstorm"],
#     "agents":   ["business-analyst.md", "tech-lead.md"]
#   },
#   "ai-dev": { ... }
# }
# ─────────────────────────────────────────────────────────────────────────────

registry_init() {
  mkdir -p "$CLAUDE_DIR"
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

# Devuelve "yes" si el plugin está en el registro, "no" si no
registry_has() {
  local name="$1"
  local result
  result=$(python3 - <<EOF 2>/dev/null
import json
try:
    r = json.load(open('$REGISTRY'))
    print("yes" if '$name' in r else "no")
except Exception:
    print("no")
EOF
)
  [[ "$result" == "yes" ]]
}

# Agrega o actualiza la entrada de un plugin en el registro
registry_set() {
  local name="$1"
  local skills_list="$2"   # espacio-separado
  local agents_list="$3"   # espacio-separado

  python3 - <<EOF
import json

try:
    r = json.load(open('$REGISTRY'))
except Exception:
    r = {}

skills = [s for s in """$skills_list""".split() if s]
agents = [a for a in """$agents_list""".split() if a]

r['$name'] = {
    'commands': 'commands/$name',
    'skills':   skills,
    'agents':   agents,
}
json.dump(r, open('$REGISTRY', 'w'), indent=2)
print(f"  registry: {len(skills)} skill(s), {len(agents)} agent(s) registrados para '$name'")
EOF
}

# Lee un campo del registro de un plugin (skills o agents) — salida json array
registry_get() {
  local name="$1"
  local field="$2"
  python3 - <<EOF
import json
try:
    r = json.load(open('$REGISTRY'))
    items = r.get('$name', {}).get('$field', [])
    for i in items:
        print(i)
except Exception:
    pass
EOF
}

# Elimina la entrada del plugin del registro
registry_del() {
  local name="$1"
  python3 - <<EOF
import json
try:
    r = json.load(open('$REGISTRY'))
    r.pop('$name', None)
    json.dump(r, open('$REGISTRY', 'w'), indent=2)
except Exception:
    pass
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
# Resolución de manifests
# ─────────────────────────────────────────────────────────────────────────────

plugin_name_from_manifest() {
  local manifest="$1"
  python3 -c "import json; d=json.load(open('$manifest')); print(d['name'])" 2>/dev/null \
    || basename "$(dirname "$(dirname "$manifest")")"
}

resolve_plugin_dir() {
  local name="$1"
  if [[ -d "$PLUGINS_DIR/$name" ]]; then
    echo "$PLUGINS_DIR/$name"
    return
  fi
  for dir in "$PLUGINS_DIR"/*/; do
    local manifest="$dir/.claude-plugin/plugin.json"
    [[ -f "$manifest" ]] || continue
    local pname
    pname=$(plugin_name_from_manifest "$manifest")
    if [[ "$pname" == "$name" ]]; then
      echo "$dir"
      return
    fi
  done
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Migración: convierte cualquier symlink legacy en .claude/ a copia real
# y construye el registro a partir de lo que encuentra.
# Se ejecuta automáticamente antes de cualquier install/remove.
# ─────────────────────────────────────────────────────────────────────────────
migrate_legacy() {
  local migrated=false

  # ── .claude/skills como symlink único ──────────────────────────────────────
  if [[ -L "$CLAUDE_DIR/skills" ]]; then
    log_warn "Migrando .claude/skills (symlink legacy → carpeta con copias)..."
    local old_target
    old_target=$(readlink "$CLAUDE_DIR/skills")
    rm "$CLAUDE_DIR/skills"
    mkdir -p "$CLAUDE_DIR/skills"

    if [[ -d "$old_target" ]]; then
      for d in "$old_target"/*/; do
        [[ -d "$d" ]] || continue
        local sname
        sname=$(basename "$d")
        if [[ -n "$DRY_RUN" ]]; then
          log_dry "cp -r $d → .claude/skills/$sname"
        else
          cp -r "$d" "$CLAUDE_DIR/skills/$sname"
          log_ok "skill $sname (migrado)"
        fi
      done
    fi
    migrated=true
  fi

  # ── .claude/agents como symlink único ──────────────────────────────────────
  if [[ -L "$CLAUDE_DIR/agents" ]]; then
    log_warn "Migrando .claude/agents (symlink legacy → carpeta con copias)..."
    local old_target
    old_target=$(readlink "$CLAUDE_DIR/agents")
    rm "$CLAUDE_DIR/agents"
    mkdir -p "$CLAUDE_DIR/agents"

    if [[ -d "$old_target" ]]; then
      for f in "$old_target"/*.md; do
        [[ -f "$f" ]] || continue
        local aname
        aname=$(basename "$f")
        if [[ -n "$DRY_RUN" ]]; then
          log_dry "cp $f → .claude/agents/$aname"
        else
          cp "$f" "$CLAUDE_DIR/agents/$aname"
          log_ok "agent $aname (migrado)"
        fi
      done
    fi
    migrated=true
  fi

  # ── symlinks individuales dentro de skills/ ─────────────────────────────────
  if [[ -d "$CLAUDE_DIR/skills" ]]; then
    while IFS= read -r link; do
      [[ -L "$link" ]] || continue
      local target sname
      target=$(readlink "$link")
      sname=$(basename "$link")
      if [[ -n "$DRY_RUN" ]]; then
        log_dry "convertir symlink skill $sname → copia"
      else
        rm "$link"
        cp -r "$target" "$CLAUDE_DIR/skills/$sname"
        log_ok "skill $sname convertido a copia"
      fi
      migrated=true
    done < <(find "$CLAUDE_DIR/skills" -maxdepth 1 -type l 2>/dev/null || true)
  fi

  # ── symlinks individuales dentro de agents/ ─────────────────────────────────
  if [[ -d "$CLAUDE_DIR/agents" ]]; then
    while IFS= read -r link; do
      [[ -L "$link" ]] || continue
      local target aname
      target=$(readlink "$link")
      aname=$(basename "$link")
      if [[ -n "$DRY_RUN" ]]; then
        log_dry "convertir symlink agent $aname → copia"
      else
        rm "$link"
        cp "$target" "$CLAUDE_DIR/agents/$aname"
        log_ok "agent $aname convertido a copia"
      fi
      migrated=true
    done < <(find "$CLAUDE_DIR/agents" -maxdepth 1 -type l 2>/dev/null || true)
  fi

  # ── symlinks dentro de commands/ ────────────────────────────────────────────
  if [[ -d "$CLAUDE_DIR/commands" ]]; then
    for ns_dir in "$CLAUDE_DIR/commands"/*/; do
      [[ -d "$ns_dir" ]] || continue
      while IFS= read -r link; do
        [[ -L "$link" ]] || continue
        local target fname
        target=$(readlink "$link")
        fname=$(basename "$link")
        if [[ -n "$DRY_RUN" ]]; then
          log_dry "convertir symlink command $fname → copia"
        else
          rm "$link"
          cp "$target" "$ns_dir/$fname"
          log_ok "command $fname convertido a copia"
        fi
        migrated=true
      done < <(find "$ns_dir" -maxdepth 1 -type l 2>/dev/null || true)
    done
  fi

  $migrated && [[ -z "$DRY_RUN" ]] && log_info "Migración completada. Reconstruyendo registro..."

  # ── Reconstruir registro desde el estado actual de .claude/ ─────────────────
  # Para cada plugin conocido, inferir qué tiene instalado
  if $migrated && [[ -z "$DRY_RUN" ]]; then
    for plugin_dir in "$PLUGINS_DIR"/*/; do
      [[ -d "$plugin_dir" ]] || continue
      local manifest="$plugin_dir/.claude-plugin/plugin.json"
      [[ -f "$manifest" ]] || continue
      local pname
      pname=$(plugin_name_from_manifest "$manifest")

      registry_has "$pname" && continue   # ya registrado, no sobreescribir

      local skills_found="" agents_found=""

      # ¿Cuáles de sus skills están presentes en .claude/skills/?
      if [[ -d "$plugin_dir/skills" ]]; then
        for d in "$plugin_dir/skills/"/*/; do
          [[ -d "$d" ]] || continue
          local sname
          sname=$(basename "$d")
          [[ -d "$CLAUDE_DIR/skills/$sname" ]] && skills_found="$skills_found $sname"
        done
      fi

      # ¿Cuáles de sus agents están presentes en .claude/agents/?
      if [[ -d "$plugin_dir/agents" ]]; then
        for f in "$plugin_dir/agents/"*.md; do
          [[ -f "$f" ]] || continue
          local aname
          aname=$(basename "$f")
          [[ -f "$CLAUDE_DIR/agents/$aname" ]] && agents_found="$agents_found $aname"
        done
      fi

      # Solo registrar si tiene algo instalado
      if [[ -d "$CLAUDE_DIR/commands/$pname" ]] || \
         [[ -n "${skills_found// /}" ]] || \
         [[ -n "${agents_found// /}" ]]; then
        registry_set "$pname" "$skills_found" "$agents_found" > /dev/null
        log_ok "Plugin '$pname' registrado en el registro"
      fi
    done
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# install_plugin <plugin_dir> <plugin_name>
# ─────────────────────────────────────────────────────────────────────────────
install_plugin() {
  local plugin_dir="$1"
  local plugin_name="$2"

  echo -e "\n${GREEN}install${RESET} ${BOLD}$plugin_name${RESET}  ${DIM}(${plugin_dir})${RESET}"

  if registry_has "$plugin_name" 2>/dev/null; then
    log_warn "Ya instalado. Reinstalando (sobreescribe archivos existentes)..."
  fi

  local installed_skills="" installed_agents=""

  # ── commands ──────────────────────────────────────────────────────────────
  if [[ -d "$plugin_dir/commands" ]]; then
    local cmd_dest="$CLAUDE_DIR/commands/$plugin_name"
    local count=0

    if [[ -n "$DRY_RUN" ]]; then
      count=$(find "$plugin_dir/commands" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
      log_dry "mkdir $cmd_dest"
      log_dry "cp $count command(s) → commands/$plugin_name/"
    else
      mkdir -p "$cmd_dest"
      for f in "$plugin_dir/commands/"*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$cmd_dest/$(basename "$f")"
        log_ok "command  $(basename "$f")"
        ((count++)) || true
      done
      [[ $count -gt 0 ]] && log_info "$count command(s) → commands/$plugin_name/"
    fi
  fi

  # ── skills ────────────────────────────────────────────────────────────────
  if [[ -d "$plugin_dir/skills" ]]; then
    mkdir -p "$CLAUDE_DIR/skills"
    local count=0

    for d in "$plugin_dir/skills/"/*/; do
      [[ -d "$d" ]] || continue
      local skill_name
      skill_name=$(basename "$d")
      local dest="$CLAUDE_DIR/skills/$skill_name"

      # Verificar si otro plugin ya instaló este skill
      if [[ -d "$dest" ]] && ! registry_has "$plugin_name" 2>/dev/null; then
        local owner
        owner=$(python3 - <<EOF 2>/dev/null || echo "desconocido"
import json
try:
    r = json.load(open('$REGISTRY'))
    for pname, data in r.items():
        if '$skill_name' in data.get('skills', []):
            print(pname)
            break
except Exception:
    pass
EOF
)
        log_warn "skill $skill_name ya instalado por '$owner' — omitido"
        continue
      fi

      if [[ -n "$DRY_RUN" ]]; then
        log_dry "cp -r $d → .claude/skills/$skill_name"
        installed_skills="$installed_skills $skill_name"
        ((count++)) || true
        continue
      fi

      rm -rf "$dest"
      cp -r "$d" "$dest"
      log_ok "skill    $skill_name"
      installed_skills="$installed_skills $skill_name"
      ((count++)) || true
    done
    [[ $count -gt 0 ]] && log_info "$count skill(s) copiados"
  fi

  # ── agents ────────────────────────────────────────────────────────────────
  if [[ -d "$plugin_dir/agents" ]]; then
    mkdir -p "$CLAUDE_DIR/agents"
    local count=0

    for f in "$plugin_dir/agents/"*.md; do
      [[ -f "$f" ]] || continue
      local agent_name
      agent_name=$(basename "$f")
      local dest="$CLAUDE_DIR/agents/$agent_name"

      # Verificar si otro plugin ya instaló este agent
      if [[ -f "$dest" ]] && ! registry_has "$plugin_name" 2>/dev/null; then
        local owner
        owner=$(python3 - <<EOF 2>/dev/null || echo "desconocido"
import json
try:
    r = json.load(open('$REGISTRY'))
    for pname, data in r.items():
        if '$agent_name' in data.get('agents', []):
            print(pname)
            break
except Exception:
    pass
EOF
)
        log_warn "agent $agent_name ya instalado por '$owner' — omitido"
        continue
      fi

      if [[ -n "$DRY_RUN" ]]; then
        log_dry "cp $f → .claude/agents/$agent_name"
        installed_agents="$installed_agents $agent_name"
        ((count++)) || true
        continue
      fi

      cp "$f" "$dest"
      log_ok "agent    $agent_name"
      installed_agents="$installed_agents $agent_name"
      ((count++)) || true
    done
    [[ $count -gt 0 ]] && log_info "$count agent(s) copiados"
  fi

  # ── Actualizar registro ────────────────────────────────────────────────────
  if [[ -z "$DRY_RUN" ]]; then
    registry_set "$plugin_name" "$installed_skills" "$installed_agents"
    echo -e "  ${GREEN}✓ $plugin_name instalado${RESET}"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# remove_plugin <plugin_name>
# ─────────────────────────────────────────────────────────────────────────────
remove_plugin() {
  local plugin_name="$1"

  echo -e "\n${RED}remove${RESET}  ${BOLD}$plugin_name${RESET}"

  if ! registry_has "$plugin_name" 2>/dev/null; then
    log_warn "'$plugin_name' no está en el registro. Puede que no esté instalado."
  fi

  # ── commands ──────────────────────────────────────────────────────────────
  local cmd_dir="$CLAUDE_DIR/commands/$plugin_name"
  if [[ -d "$cmd_dir" ]]; then
    if [[ -n "$DRY_RUN" ]]; then
      local count
      count=$(find "$cmd_dir" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
      log_dry "rm -rf commands/$plugin_name/  ($count command(s))"
    else
      local count
      count=$(find "$cmd_dir" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
      rm -rf "$cmd_dir"
      log_remove "commands/$plugin_name/ ($count command(s))"
    fi
  else
    log_skip "commands/$plugin_name/ no encontrado"
  fi

  # ── skills — solo los registrados bajo este plugin ────────────────────────
  if [[ -d "$CLAUDE_DIR/skills" ]]; then
    local count=0
    while IFS= read -r skill_name; do
      [[ -z "$skill_name" ]] && continue
      local dest="$CLAUDE_DIR/skills/$skill_name"
      if [[ -d "$dest" ]]; then
        if [[ -n "$DRY_RUN" ]]; then
          log_dry "rm -rf .claude/skills/$skill_name"
        else
          rm -rf "$dest"
          log_remove "skill    $skill_name"
        fi
        ((count++)) || true
      else
        log_skip "skill $skill_name no encontrado en .claude/skills/"
      fi
    done < <(registry_get "$plugin_name" "skills")
    [[ $count -eq 0 ]] && log_skip "no hay skills registrados para $plugin_name"
  fi

  # ── agents — solo los registrados bajo este plugin ────────────────────────
  if [[ -d "$CLAUDE_DIR/agents" ]]; then
    local count=0
    while IFS= read -r agent_name; do
      [[ -z "$agent_name" ]] && continue
      local dest="$CLAUDE_DIR/agents/$agent_name"
      if [[ -f "$dest" ]]; then
        if [[ -n "$DRY_RUN" ]]; then
          log_dry "rm .claude/agents/$agent_name"
        else
          rm "$dest"
          log_remove "agent    $agent_name"
        fi
        ((count++)) || true
      else
        log_skip "agent $agent_name no encontrado en .claude/agents/"
      fi
    done < <(registry_get "$plugin_name" "agents")
    [[ $count -eq 0 ]] && log_skip "no hay agents registrados para $plugin_name"
  fi

  # ── Limpiar registro ───────────────────────────────────────────────────────
  if [[ -z "$DRY_RUN" ]]; then
    registry_del "$plugin_name"
    echo -e "  ${RED}✗ $plugin_name eliminado del registro${RESET}"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# cmd_list
# ─────────────────────────────────────────────────────────────────────────────
cmd_list() {
  echo -e "${BOLD}Plugins disponibles${RESET}  ${DIM}($PLUGINS_DIR)${RESET}\n"

  local found=0

  for plugin_dir in "$PLUGINS_DIR"/*/; do
    [[ -d "$plugin_dir" ]] || continue
    local manifest="$plugin_dir/.claude-plugin/plugin.json"
    local folder
    folder=$(basename "$plugin_dir")

    if [[ ! -f "$manifest" ]]; then
      echo -e "  ${YELLOW}?${RESET}  ${BOLD}$folder${RESET}  ${DIM}(sin plugin.json — omitido)${RESET}"
      ((found++)) || true
      continue
    fi

    local pname version description
    pname=$(python3 -c "import json; d=json.load(open('$manifest')); print(d.get('name','$folder'))" 2>/dev/null || echo "$folder")
    version=$(python3 -c "import json; d=json.load(open('$manifest')); print(d.get('version','-'))" 2>/dev/null || echo "-")
    description=$(python3 -c "import json; d=json.load(open('$manifest')); print(d.get('description',''))" 2>/dev/null || echo "")

    # Conteos en el plugin fuente
    local src_cmd=0 src_skill=0 src_agent=0
    [[ -d "$plugin_dir/commands" ]] && src_cmd=$(find "$plugin_dir/commands" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
    [[ -d "$plugin_dir/skills"   ]] && src_skill=$(find "$plugin_dir/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
    [[ -d "$plugin_dir/agents"   ]] && src_agent=$(find "$plugin_dir/agents" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')

    if registry_has "$pname" 2>/dev/null; then
      # Conteos instalados desde registro
      local inst_skill inst_agent
      inst_skill=$(registry_get "$pname" "skills" | grep -c . || true)
      inst_agent=$(registry_get "$pname" "agents" | grep -c . || true)
      echo -e "  ${GREEN}●${RESET}  ${BOLD}$pname${RESET}  ${DIM}v$version${RESET}  ${GREEN}[instalado]${RESET}"
      [[ -n "$description" ]] && echo -e "     ${DIM}$description${RESET}"
      echo -e "     fuente  — ${CYAN}commands:${RESET} $src_cmd  ${CYAN}skills:${RESET} $src_skill  ${CYAN}agents:${RESET} $src_agent"
      echo -e "     activos — ${CYAN}commands:${RESET} $src_cmd  ${CYAN}skills:${RESET} $inst_skill  ${CYAN}agents:${RESET} $inst_agent"
    else
      echo -e "  ${DIM}○${RESET}  ${BOLD}$pname${RESET}  ${DIM}v$version${RESET}"
      [[ -n "$description" ]] && echo -e "     ${DIM}$description${RESET}"
      echo -e "     ${CYAN}commands:${RESET} $src_cmd  ${CYAN}skills:${RESET} $src_skill  ${CYAN}agents:${RESET} $src_agent"
    fi
    echo ""
    ((found++)) || true
  done

  [[ $found -eq 0 ]] && echo -e "  ${YELLOW}Sin plugins en $PLUGINS_DIR${RESET}"

  # ── Resumen de .claude/ ────────────────────────────────────────────────────
  echo -e "${BOLD}Estado de .claude/${RESET}\n"

  local reg_ns=0 reg_skills=0 reg_agents=0
  [[ -d "$CLAUDE_DIR/commands" ]] && reg_ns=$(find "$CLAUDE_DIR/commands" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
  [[ -d "$CLAUDE_DIR/skills"   ]] && reg_skills=$(find "$CLAUDE_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
  [[ -d "$CLAUDE_DIR/agents"   ]] && reg_agents=$(find "$CLAUDE_DIR/agents" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')

  echo -e "  namespaces de commands : ${BOLD}$reg_ns${RESET}"
  echo -e "  skills instalados      : ${BOLD}$reg_skills${RESET}"
  echo -e "  agents instalados      : ${BOLD}$reg_agents${RESET}"
  echo -e "  registro               : ${DIM}$REGISTRY${RESET}"
}

# ─────────────────────────────────────────────────────────────────────────────
# cmd_install [--all | <nombre>]
# ─────────────────────────────────────────────────────────────────────────────
cmd_install() {
  local target="${1:-}"

  if [[ -z "$target" ]]; then
    log_error "Especificá un nombre o usá --all"
    echo "  Uso: $0 install <nombre>"
    echo "  Uso: $0 install --all"
    exit 1
  fi

  log_section "Plugin Installer${DRY_RUN:+ (dry-run)}"
  echo -e "  ${DIM}plugins : $PLUGINS_DIR${RESET}"
  echo -e "  ${DIM}claude  : $CLAUDE_DIR${RESET}"

  registry_init
  migrate_legacy

  if [[ "$target" == "--all" ]]; then
    local installed=0 skipped=0

    for plugin_dir in "$PLUGINS_DIR"/*/; do
      [[ -d "$plugin_dir" ]] || continue
      local manifest="$plugin_dir/.claude-plugin/plugin.json"

      if [[ ! -f "$manifest" ]]; then
        echo -e "\n${YELLOW}skip${RESET}  $(basename "$plugin_dir") — sin plugin.json"
        ((skipped++)) || true
        continue
      fi

      local pname
      pname=$(plugin_name_from_manifest "$manifest")
      install_plugin "$plugin_dir" "$pname"
      ((installed++)) || true
    done

    echo -e "\n${BOLD}Listo.${RESET} $installed instalado(s), $skipped omitido(s)."
    return
  fi

  local plugin_dir
  plugin_dir=$(resolve_plugin_dir "$target")

  if [[ -z "$plugin_dir" ]]; then
    log_error "Plugin '$target' no encontrado en $PLUGINS_DIR"
    exit 1
  fi

  local manifest="$plugin_dir/.claude-plugin/plugin.json"
  if [[ ! -f "$manifest" ]]; then
    log_error "plugin.json no encontrado en $plugin_dir/.claude-plugin/"
    exit 1
  fi

  local pname
  pname=$(plugin_name_from_manifest "$manifest")
  install_plugin "$plugin_dir" "$pname"
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# cmd_remove [--all | <nombre>]
# ─────────────────────────────────────────────────────────────────────────────
cmd_remove() {
  local target="${1:-}"

  if [[ -z "$target" ]]; then
    log_error "Especificá un nombre o usá --all"
    echo "  Uso: $0 remove <nombre>"
    echo "  Uso: $0 remove --all"
    exit 1
  fi

  log_section "Plugin Remover${DRY_RUN:+ (dry-run)}"

  registry_init

  if [[ "$target" == "--all" ]]; then
    local removed=0

    for plugin_dir in "$PLUGINS_DIR"/*/; do
      [[ -d "$plugin_dir" ]] || continue
      local manifest="$plugin_dir/.claude-plugin/plugin.json"
      [[ -f "$manifest" ]] || continue
      local pname
      pname=$(plugin_name_from_manifest "$manifest")
      registry_has "$pname" 2>/dev/null || continue
      remove_plugin "$pname"
      ((removed++)) || true
    done

    echo -e "\n${BOLD}Listo.${RESET} $removed plugin(s) eliminado(s)."
    return
  fi

  remove_plugin "$target"
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# cmd_help
# ─────────────────────────────────────────────────────────────────────────────
cmd_help() {
  echo -e "${BOLD}plugin.sh${RESET} — Gestor de plugins para Claude Code\n"
  echo -e "  ${CYAN}Comandos:${RESET}"
  echo "    list                  Listar plugins y estado del registro"
  echo "    install <nombre>      Instalar un plugin"
  echo "    install --all         Instalar todos los plugins"
  echo "    remove  <nombre>      Eliminar un plugin (por registro)"
  echo "    remove  --all         Eliminar todos los plugins instalados"
  echo ""
  echo -e "  ${CYAN}Flags:${RESET}"
  echo "    --dry-run             Mostrar cambios sin ejecutar"
  echo ""
  echo -e "  ${CYAN}Ejemplos:${RESET}"
  echo "    ./plugin.sh list"
  echo "    ./plugin.sh install ai-dev"
  echo "    ./plugin.sh install --all"
  echo "    ./plugin.sh remove  plan"
  echo "    ./plugin.sh remove  --all"
  echo "    ./plugin.sh install ai-dev --dry-run"
  echo ""
  echo -e "  ${CYAN}Registro:${RESET}"
  echo "    .claude/.plugins-registry.json"
  echo "    Fuente de verdad de qué instaló cada plugin."
  echo "    Permite remove preciso sin adivinar por rutas de archivos."
}

# ─────────────────────────────────────────────────────────────────────────────
# Parseo de argumentos
# ─────────────────────────────────────────────────────────────────────────────
COMMAND=""
PLUGIN_ARG=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN="true" ;;
    list|install|remove|help) COMMAND="$arg" ;;
    *) PLUGIN_ARG="$arg" ;;
  esac
done

case "$COMMAND" in
  list)    cmd_list ;;
  install) cmd_install "$PLUGIN_ARG" ;;
  remove)  cmd_remove  "$PLUGIN_ARG" ;;
  help)    cmd_help ;;
  *)
    log_error "Comando desconocido: '${COMMAND:-}'"
    echo ""
    cmd_help
    exit 1
    ;;
esac
