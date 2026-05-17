#!/bin/bash
# ============================================================
# agent-config-plugin: Scaffold agent/sub-agent configuration
# Generates the full skills/ + AGENTS.md structure for a project
#
# Usage:
#   ./scaffold.sh                         # Auto-detect project
#   ./scaffold.sh MyProject               # Named project
#   ./scaffold.sh --scopes api,ui,sdk     # Per-scope AGENTS.md
#   ./scaffold.sh --minimal               # Root only
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PROJECT_NAME=""
SCOPES=""
MINIMAL=false

show_help() {
    echo "Usage: $0 [PROJECT_NAME] [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --scopes api,ui,sdk   Generate per-scope AGENTS.md"
    echo "  --minimal             Root AGENTS.md + skills/ only"
    echo "  --help                Show this help"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --scopes)   SCOPES="$2"; shift 2 ;;
        --minimal)  MINIMAL=true; shift ;;
        --help|-h)  show_help; exit 0 ;;
        --*)        echo -e "${RED}Unknown option: $1${NC}"; show_help; exit 1 ;;
        *)          PROJECT_NAME="$1"; shift ;;
    esac
done

# Auto-detect project name
if [ -z "$PROJECT_NAME" ]; then
    if [ -f "$REPO_ROOT/package.json" ]; then
        PROJECT_NAME=$(python3 -c "import json; d=json.load(open('package.json')); print(d.get('name',''))" 2>/dev/null || true)
    elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
        PROJECT_NAME=$(grep '^name' pyproject.toml 2>/dev/null | head -1 | sed 's/name = "\(.*\)"/\1/' | tr -d ' "' || true)
    elif [ -f "$REPO_ROOT/go.mod" ]; then
        PROJECT_NAME=$(head -1 go.mod | awk '{print $2}' | xargs basename 2>/dev/null || true)
    fi
    [ -z "$PROJECT_NAME" ] && PROJECT_NAME=$(basename "$REPO_ROOT")
fi

# Auto-detect scopes if not specified and not minimal
if [ -z "$SCOPES" ] && [ "$MINIMAL" = false ]; then
    detected=()
    [ -d "$REPO_ROOT/api" ]      && detected+=("api")
    [ -d "$REPO_ROOT/ui" ]       && detected+=("ui")
    [ -d "$REPO_ROOT/frontend" ] && detected+=("ui")
    [ -d "$REPO_ROOT/sdk" ]      && detected+=("sdk")
    [ -d "$REPO_ROOT/backend" ]  && detected+=("api")
    SCOPES=$(IFS=,; echo "${detected[*]}")
fi

echo ""
echo -e "${BOLD}🤖 Agent Config — Scaffold${NC}"
echo "============================="
echo -e "${BLUE}Project: ${NC}$PROJECT_NAME"
echo -e "${BLUE}Root:    ${NC}$REPO_ROOT"
[ -n "$SCOPES" ] && echo -e "${BLUE}Scopes:  ${NC}$SCOPES"
[ "$MINIMAL" = true ] && echo -e "${YELLOW}Mode: minimal${NC}"
echo ""

# ============================================================
# 1. Create skills/ structure
# ============================================================
echo -e "${YELLOW}[1/5] Creating skills/ structure...${NC}"

mkdir -p "$REPO_ROOT/skills/skill-sync/assets"
mkdir -p "$REPO_ROOT/skills/starter"

# Copy scripts from plugin
cp "$PLUGIN_ROOT/scripts/setup.sh"  "$REPO_ROOT/skills/setup.sh"
cp "$PLUGIN_ROOT/scripts/sync.sh"   "$REPO_ROOT/skills/skill-sync/assets/sync.sh"
chmod +x "$REPO_ROOT/skills/setup.sh"
chmod +x "$REPO_ROOT/skills/skill-sync/assets/sync.sh"

echo -e "${GREEN}  ✓ skills/setup.sh${NC}"
echo -e "${GREEN}  ✓ skills/skill-sync/assets/sync.sh${NC}"

# Copy skill templates
cp "$PLUGIN_ROOT/skills/agents-sync/SKILL.md" "$REPO_ROOT/skills/skill-sync/SKILL.md"

# ============================================================
# 2. Generate starter skill stub
# ============================================================
echo -e "${YELLOW}[2/5] Generating starter skill stub...${NC}"

cat > "$REPO_ROOT/skills/starter/SKILL.md" << HEREDOC
---
name: starter
description: >
  Starter skill template for $PROJECT_NAME. Replace this with your first
  domain-specific skill.
  Trigger: working on $PROJECT_NAME core functionality.
license: MIT
metadata:
  author: $PROJECT_NAME
  version: "1.0"
  scope: [root]
  auto_invoke:
    - "Working on $PROJECT_NAME core functionality"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Purpose

Template skill for $PROJECT_NAME. Replace this with your project-specific knowledge.

## Critical Rules

### ALWAYS
- Follow the project conventions defined in AGENTS.md

### NEVER
- Skip reading the relevant skill before working on a domain task

## Commands

\`\`\`bash
# Sync AGENTS.md after skill changes
./skills/skill-sync/assets/sync.sh

# Configure AI assistants
./skills/setup.sh
\`\`\`

## Checklist

- [ ] AGENTS.md Auto-invoke section is up to date
- [ ] All skills have metadata.scope and metadata.auto_invoke
HEREDOC

echo -e "${GREEN}  ✓ skills/starter/SKILL.md${NC}"

# ============================================================
# 3. Generate root AGENTS.md
# ============================================================
echo -e "${YELLOW}[3/5] Generating root AGENTS.md...${NC}"

if [ -f "$REPO_ROOT/AGENTS.md" ]; then
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/AGENTS.md.backup.$(date +%s)"
    echo -e "${YELLOW}  ⚠ Existing AGENTS.md backed up${NC}"
fi

cat > "$REPO_ROOT/AGENTS.md" << HEREDOC
# $PROJECT_NAME - AI Agent Ruleset

> **Skills Reference**: For detailed patterns, use these skills:
> - [\`skill-sync\`](./skills/skill-sync/SKILL.md) - Sync skill metadata to AGENTS.md Auto-invoke tables
> - [\`starter\`](./skills/starter/SKILL.md) - Starter skill template

### Auto-invoke Skills

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| After creating or modifying a SKILL.md | \`skill-sync\` |
| Regenerating AGENTS.md Auto-invoke tables | \`skill-sync\` |
| Working on $PROJECT_NAME core functionality | \`starter\` |

---

## CRITICAL RULES - NON-NEGOTIABLE

<!-- Add your project-critical rules here -->
- ALWAYS: Read the relevant skill before working on a domain task
- ALWAYS: Run \`./skills/skill-sync/assets/sync.sh\` after creating/modifying skills
- NEVER: Skip the QA checklist before committing

---

## TECH STACK

<!-- Auto-detected or fill in manually -->
$([ -f "$REPO_ROOT/package.json" ] && echo "Node.js $(node --version 2>/dev/null || echo '(unknown)') + see package.json")
$([ -f "$REPO_ROOT/pyproject.toml" ] && echo "Python — see pyproject.toml")
$([ -f "$REPO_ROOT/go.mod" ] && echo "Go — see go.mod")

---

## PROJECT STRUCTURE

\`\`\`
$PROJECT_NAME/
├── skills/                  # AI Agent Skills (agentskills.io)
│   ├── setup.sh             # Configure AI assistants
│   ├── skill-sync/          # Auto-sync AGENTS.md tables
│   └── {skill-name}/
│       └── SKILL.md
├── agents/                  # Sub-agent definitions (optional)
└── AGENTS.md                # This file
\`\`\`

---

## COMMANDS

\`\`\`bash
# Set up AI assistant symlinks
./skills/setup.sh

# Sync skill metadata to AGENTS.md
./skills/skill-sync/assets/sync.sh

# Preview what sync would change
./skills/skill-sync/assets/sync.sh --dry-run

# Sync a specific scope only
./skills/skill-sync/assets/sync.sh --scope api
\`\`\`

---

## QA CHECKLIST

- [ ] All new skills have \`metadata.scope\` and \`metadata.auto_invoke\`
- [ ] AGENTS.md Auto-invoke section is up to date (run sync.sh)
- [ ] \`./skills/setup.sh\` has been run after cloning
HEREDOC

echo -e "${GREEN}  ✓ AGENTS.md${NC}"

# Blueprint §5: .claude.md is a SYMLINK → AGENTS.md (never a copy)
# This ensures Claude Code always reads the live source of truth
ln -sf "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.claude.md"
echo -e "${GREEN}  ✓ .claude.md -> AGENTS.md  (symlink — Blueprint §5)${NC}"

# ============================================================
# 4. Generate per-scope AGENTS.md files
# ============================================================
if [ -n "$SCOPES" ] && [ "$MINIMAL" = false ]; then
    echo -e "${YELLOW}[4/5] Generating per-scope AGENTS.md files...${NC}"

    IFS=',' read -ra scope_list <<< "$SCOPES"
    for scope in "${scope_list[@]}"; do
        scope=$(echo "$scope" | tr -d ' ')
        scope_dir="$REPO_ROOT/$scope"
        
        [ ! -d "$scope_dir" ] && { echo -e "${YELLOW}  ⚠ Directory $scope/ not found, skipping${NC}"; continue; }

        scope_title=$(echo "${scope^}")  # Capitalize first letter

        cat > "$scope_dir/AGENTS.md" << HEREDOC
# $PROJECT_NAME $scope_title - AI Agent Ruleset

> **Skills Reference**: For detailed patterns, use these skills:
> - [\`skill-sync\`](../skills/skill-sync/SKILL.md) - Sync skill metadata to AGENTS.md

### Auto-invoke Skills

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|

---

## CRITICAL RULES - NON-NEGOTIABLE

<!-- Add $scope-specific rules here -->

---

## TECH STACK

<!-- Add $scope tech stack here -->

---

## COMMANDS

\`\`\`bash
# Add $scope-specific commands here
\`\`\`

---

## QA CHECKLIST

- [ ] All $scope skills have \`metadata.scope: [$scope]\` set
- [ ] AGENTS.md Auto-invoke section is up to date
HEREDOC

        echo -e "${GREEN}  ✓ $scope/AGENTS.md${NC}"

        # Blueprint §5: each scope also gets its own .claude.md symlink
        ln -sf "$scope_dir/AGENTS.md" "$scope_dir/.claude.md"
        echo -e "${GREEN}  ✓ $scope/.claude.md -> $scope/AGENTS.md  (symlink)${NC}"
    done
else
    echo -e "${YELLOW}[4/5] Skipping per-scope AGENTS.md (minimal mode or no scopes detected)${NC}"
fi

# ============================================================
# 5. Generate skills/README.md
# ============================================================
echo -e "${YELLOW}[5/5] Generating skills/README.md...${NC}"

cat > "$REPO_ROOT/skills/README.md" << HEREDOC
# AI Agent Skills — $PROJECT_NAME

This directory contains **Agent Skills** following the [agentskills.io](https://agentskills.io) standard.

## Setup

\`\`\`bash
./skills/setup.sh
\`\`\`

| Tool | Location |
|------|---------|
| Claude Code | \`.claude/skills/\` |
| Codex (OpenAI) | \`.codex/skills/\` |
| Gemini CLI | \`.gemini/skills/\` |
| GitHub Copilot | \`.github/copilot-instructions.md\` |

## Available Skills

| Skill | Description |
|-------|-------------|
| \`starter\` | Starter template — replace with domain skills |
| \`skill-sync\` | Sync skill metadata to AGENTS.md Auto-invoke tables |

## Adding a New Skill

1. Create \`skills/{name}/SKILL.md\` with required frontmatter
2. Add \`metadata.scope\` and \`metadata.auto_invoke\`
3. Run \`./skills/skill-sync/assets/sync.sh\`
4. Verify AGENTS.md was updated

## Sync

\`\`\`bash
./skills/skill-sync/assets/sync.sh          # Full sync
./skills/skill-sync/assets/sync.sh --dry-run  # Preview
./skills/skill-sync/assets/sync.sh --scope ui # Scope-limited
\`\`\`
HEREDOC

echo -e "${GREEN}  ✓ skills/README.md${NC}"

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo -e "${GREEN}✅ Agent configuration scaffolded for $PROJECT_NAME!${NC}"
echo ""
echo "Generated:"
echo "  • AGENTS.md"
echo "  • .claude.md -> AGENTS.md  (symlink)"
[ -n "$SCOPES" ] && IFS=',' read -ra sl <<< "$SCOPES" && for s in "${sl[@]}"; do echo "  • $s/AGENTS.md + $s/.claude.md (symlink)"; done
echo "  • skills/setup.sh"
echo "  • skills/README.md"
echo "  • skills/skill-sync/SKILL.md"
echo "  • skills/skill-sync/assets/sync.sh"
echo "  • skills/starter/SKILL.md"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. ./skills/setup.sh          # Configure your AI assistant"
echo "  2. Edit skills/starter/SKILL.md  # Add your first domain skill"
echo "  3. ./skills/skill-sync/assets/sync.sh  # Sync AGENTS.md"
