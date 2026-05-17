---
name: skill-designer
description: >
  Creates a new SKILL.md file following the agentskills.io standard with
  correct frontmatter (name, description, metadata.scope, metadata.auto_invoke).
  Trigger: when user wants to create a new skill, add a new AI skill, write a
  SKILL.md, or teach the AI how to perform a specific task.
license: MIT
metadata:
  author: agent-config-plugin
  version: "1.0"
  scope: [root]
  auto_invoke:
    - "Creating a new AI agent skill"
    - "Writing a new SKILL.md"
    - "Adding a skill to the project"
    - "Teaching the AI a new domain-specific pattern"
allowed-tools: Read, Edit, Write, Glob, Grep
---

## Purpose

Design and generate a well-structured `SKILL.md` file that an AI agent can
reliably auto-load. Skills are the primary mechanism for injecting
project-specific knowledge into AI coding assistants.

---

## Required Frontmatter

Every SKILL.md MUST include:

```yaml
---
name: skill-name                  # kebab-case, matches directory name
description: >
  One-paragraph description. This is the auto-trigger text — make it
  specific and "pushy" with explicit trigger phrases.
  Trigger: when user does X, Y, or Z.
license: MIT                      # or Apache-2.0
metadata:
  author: your-name
  version: "1.0"
  scope: [root]                   # root | ui | api | sdk | mcp_server
  auto_invoke:
    - "Trigger action 1"          # must match actions in AGENTS.md table
    - "Trigger action 2"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---
```

### Scope Values

| Value | Corresponding AGENTS.md |
|-------|------------------------|
| `root` | `./AGENTS.md` |
| `ui` | `./ui/AGENTS.md` |
| `api` | `./api/AGENTS.md` |
| `sdk` | `./sdk/AGENTS.md` |
| `mcp_server` | `./mcp_server/AGENTS.md` |

Multiple scopes allowed: `scope: [ui, api]`

---

## Skill Content Structure

Follow this template for the body of SKILL.md:

```markdown
## Purpose
One sentence: what this skill teaches the AI.

## When This Skill Is Invoked
List the exact actions from auto_invoke, plus any related context.
Reference $ARGUMENTS if user provides input.

## Critical Rules
### ALWAYS
- Rule 1
- Rule 2

### NEVER
- Anti-pattern 1
- Anti-pattern 2

## Patterns / Examples
Minimal code examples showing the correct approach.

## Decision Trees (optional)
For branching logic — when to use X vs Y.

## Commands
Bash commands relevant to this skill's domain.

## Checklist
- [ ] Verification step 1
- [ ] Verification step 2
```

---

## Quality Rules

1. **Under 500 lines** — link to external docs instead of duplicating
2. **Critical rules first** — ALWAYS/NEVER before examples
3. **$ARGUMENTS** — use when skill accepts user input
4. **Description is the trigger** — write it to match real user queries
5. **Minimal examples** — patterns not tutorials; one example per concept
6. **After creating** — always run `./skills/skill-sync/assets/sync.sh`

---

## Auto-invoke Description Writing Guide

Good auto_invoke entries are:
- **Action-oriented**: "Creating/modifying X", "Writing tests for Y"
- **Specific**: "Writing Django migrations" not "Doing database work"
- **Matching user intent**: think "what would the user say to trigger this?"

Bad:
```yaml
auto_invoke: "Working on the project"  # too vague
```

Good:
```yaml
auto_invoke:
  - "Creating PostgreSQL migration files"
  - "Running makemigrations or pgmakemigrations"
  - "Writing data backfill scripts"
```

---

## Skill Directory Structure

```
skills/
└── {skill-name}/
    ├── SKILL.md          ← required — instructions + frontmatter
    ├── assets/           ← optional — templates, schemas, config files
    ├── scripts/          ← optional — executable helpers
    └── references/       ← optional — links to local documentation
```

---

## Usage

```
/agent-config:skill-designer django-migrations
/agent-config:skill-designer react-components --scope ui
/agent-config:skill-designer "api endpoint testing" --scope api
```

After generating the skill:
1. Review the generated `skills/{name}/SKILL.md`
2. Run `./skills/skill-sync/assets/sync.sh`
3. Verify AGENTS.md updated with the new auto_invoke row
