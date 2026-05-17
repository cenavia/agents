---
name: agent-scaffold
description: >
  Scaffolds a complete agent/sub-agent project configuration from scratch.
  Generates AGENTS.md files per scope, skills/ directory layout, setup.sh for
  multi-AI-assistant support, and the skill-sync pipeline.
  Trigger: whenever the user wants to initialize a new agent project, set up
  agent configuration in an existing repo, or add agent/sub-agent support.
license: MIT
metadata:
  author: agent-config-plugin
  version: "1.0"
  scope: [root]
  auto_invoke:
    - "Initializing a new agent/sub-agent project"
    - "Adding agent configuration to an existing repo"
    - "Setting up skills/ and AGENTS.md from scratch"
allowed-tools: Read, Edit, Write, Glob, Bash
---

## Purpose

Scaffold the full **agent orchestration layer** for a project following the
[agentskills.io](https://agentskills.io) open standard, which is the same
pattern used by Prowler, one of the most advanced open-source implementations.

---

## When This Skill Is Invoked

Use `$ARGUMENTS` to extract the user's intent:
- If `$ARGUMENTS` contains a project name → use it, otherwise infer from `pwd`
- If `$ARGUMENTS` mentions scopes (api, ui, sdk) → generate per-scope AGENTS.md
- If `$ARGUMENTS` says `--minimal` → generate only root AGENTS.md + skills/

---

## Scaffold Algorithm

### Step 1 — Detect Project Shape

```bash
ls -la                     # detect existing structure
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null
find . -maxdepth 2 -name "AGENTS.md" 2>/dev/null
```

### Step 2 — Determine Scopes

Ask: does the project have separate `api/`, `ui/`, `sdk/` subdirectories?

| Found directory | Generate AGENTS.md at |
|---|---|
| `api/` or `backend/` | `api/AGENTS.md` |
| `ui/` or `frontend/` or `web/` | `ui/AGENTS.md` |
| `sdk/` or `lib/` | `sdk/AGENTS.md` |
| Always | `AGENTS.md` (root) |

### Step 3 — Generate Root AGENTS.md + `.claude.md` Symlink

> **Blueprint §5 rule**: `.claude.md` is ALWAYS a **symlink** to `AGENTS.md`,
> never a copy. This guarantees Claude Code reads the live source of truth.

```bash
# After writing AGENTS.md:
ln -sf "$(pwd)/AGENTS.md" "$(pwd)/.claude.md"
```

The correct project layout (Blueprint §5):

```
/
├── AGENTS.md              ← source of truth — edit this
├── .claude.md             ← symlink → AGENTS.md  (Claude Code reads this)
├── api/
│   ├── AGENTS.md          ← api-scope rules (Django 5.1 / PostgreSQL 16)
│   └── .claude.md         ← symlink → api/AGENTS.md
├── ui/
│   ├── AGENTS.md          ← ui-scope rules (Next.js 16 / React 19)
│   └── .claude.md         ← symlink → ui/AGENTS.md
└── skills/
    ├── setup.sh           ← deploys symlinks for all AI assistants
    ├── skill-sync/
    │   └── assets/sync.sh ← syncs metadata → AGENTS.md Auto-invoke tables
    └── {skill-name}/
        └── SKILL.md
```

Why symlink and not copy?
- A copy gets stale the moment `AGENTS.md` is edited
- A symlink means zero maintenance — one edit propagates everywhere
- Codex reads `AGENTS.md` natively; Claude reads `.claude.md`; both stay in sync

```markdown
# {ProjectName} - AI Agent Ruleset
...
```

### Step 4 — Generate skills/ Directory

The scaffold deploys assets from this plugin into the user's project.
Source lives at `${CLAUDE_PLUGIN_ROOT}/skills/agent-scaffold/assets/`:

```
# Assets copied into user project:
skills/
├── setup.sh                          ← from assets/setup.sh
├── README.md                         ← generated
└── skill-sync/
    ├── SKILL.md                      ← from agents-sync skill
    └── assets/
        └── sync.sh                   ← from assets/sync.sh

# Templates available at:
# ${CLAUDE_PLUGIN_ROOT}/skills/agent-scaffold/templates/
#   AGENTS.md.tpl  ← root/scope AGENTS.md template
#   SKILL.md.tpl   ← new skill stub template
#   agent.md.tpl   ← new agent definition template
```

### Step 5 — Generate setup.sh

Copy the Prowler pattern — create a `setup.sh` that:
1. Creates `.claude/skills/` symlink → `skills/`
2. Creates `.codex/skills/` symlink → `skills/`
3. Creates `.gemini/skills/` symlink → `skills/`
4. Copies AGENTS.md to `CLAUDE.md`, `GEMINI.md`
5. Copies root AGENTS.md to `.github/copilot-instructions.md`

### Step 6 — Generate sync.sh

Implement the skill-sync algorithm:
1. Parse all `skills/*/SKILL.md` YAML frontmatter
2. Extract `metadata.scope` and `metadata.auto_invoke`
3. Group rows by scope → map to AGENTS.md path
4. Replace the `### Auto-invoke Skills` section

---

## Output Checklist

- [ ] `AGENTS.md` at root (and per detected scope)
- [ ] `skills/setup.sh` (executable, multi-AI-assistant)
- [ ] `skills/skill-sync/SKILL.md`
- [ ] `skills/skill-sync/assets/sync.sh` (executable)
- [ ] `skills/README.md`
- [ ] At least one starter skill stub (`skills/starter/SKILL.md`)

---

## Usage

```
/agent-config:agent-scaffold                    # scaffold in current directory
/agent-config:agent-scaffold MyProject          # use specific project name
/agent-config:agent-scaffold --scopes api,ui    # generate per-scope AGENTS.md
/agent-config:agent-scaffold --minimal          # root AGENTS.md + skills/ only
```
