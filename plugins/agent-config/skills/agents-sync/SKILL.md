---
name: agents-sync
description: >
  Syncs skill metadata (scope, auto_invoke) to the Auto-invoke sections of
  all AGENTS.md files in the project. Trigger: after creating or modifying
  any SKILL.md, when AGENTS.md Auto-invoke tables are stale, when running
  sync.sh, or when a skill is missing from an AGENTS.md.
license: MIT
metadata:
  author: agent-config-plugin
  version: "1.0"
  scope: [root]
  auto_invoke:
    - "After creating or modifying a SKILL.md"
    - "Regenerating AGENTS.md Auto-invoke tables"
    - "Troubleshooting why a skill is missing from AGENTS.md"
    - "Running sync.sh"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Purpose

Keep every `AGENTS.md` Auto-invoke section **automatically in sync** with
skill metadata. Eliminates manual maintenance of the action→skill tables.

---

## How Sync Works

```
skills/*/SKILL.md
      ↓ parse YAML frontmatter
metadata.scope      → determines which AGENTS.md to update
metadata.auto_invoke → action rows in the table
      ↓
AGENTS.md ### Auto-invoke Skills section replaced/inserted
```

---

## Running the Sync

```bash
# Full sync
./skills/skill-sync/assets/sync.sh

# Dry run — shows changes without writing
./skills/skill-sync/assets/sync.sh --dry-run

# Scope-limited sync
./skills/skill-sync/assets/sync.sh --scope ui
./skills/skill-sync/assets/sync.sh --scope api
```

---

## Required Skill Metadata

For a skill to appear in Auto-invoke tables:

```yaml
metadata:
  scope: [root]           # MUST be present
  auto_invoke:            # MUST be present
    - "Action description that triggers this skill"
```

### Scope → AGENTS.md Mapping

| `scope` | File updated |
|---------|-------------|
| `root` | `AGENTS.md` |
| `ui` | `ui/AGENTS.md` |
| `api` | `api/AGENTS.md` |
| `sdk` | `sdk/AGENTS.md` or `prowler/AGENTS.md` |
| `mcp_server` | `mcp_server/AGENTS.md` |

---

## Troubleshooting Missing Skills

If a skill doesn't appear in AGENTS.md:

1. **Check scope**: `grep -A5 "^metadata:" skills/{name}/SKILL.md | grep scope`
2. **Check auto_invoke**: `grep -A10 "^metadata:" skills/{name}/SKILL.md | grep auto_invoke`
3. **Verify AGENTS.md exists** for the scope: `ls api/AGENTS.md ui/AGENTS.md`
4. **Run with verbose**: `bash -x ./skills/skill-sync/assets/sync.sh`
5. **Dry run first**: `./skills/skill-sync/assets/sync.sh --dry-run`

---

## Manual Sync (when sync.sh is unavailable)

If you need to manually add a skill to AGENTS.md:

1. Find the `### Auto-invoke Skills` section in the target AGENTS.md
2. Add a row to the markdown table:
   ```markdown
   | Action description from auto_invoke | `skill-name` |
   ```
3. Keep rows sorted alphabetically by Action

---

## Checklist After Modifying Skills

- [ ] `metadata.scope` is set on the modified skill
- [ ] `metadata.auto_invoke` has at least one entry
- [ ] `./skills/skill-sync/assets/sync.sh` ran without errors
- [ ] Target AGENTS.md(s) now contain the new rows
- [ ] No skills listed as "missing sync metadata" in sync output
