# {ProjectName} {Scope} - AI Agent Ruleset

> **Skills Reference**: For detailed patterns, use these skills:
> - [`skill-sync`](./skills/skill-sync/SKILL.md) - Sync skill metadata to AGENTS.md

### Auto-invoke Skills

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| After creating or modifying a SKILL.md | `skill-sync` |

---

## CRITICAL RULES - NON-NEGOTIABLE

<!-- Replace with your domain rules. Follow the ALWAYS/NEVER pattern. -->

### {Domain}
- ALWAYS: {Critical rule 1}
- ALWAYS: {Critical rule 2}
- NEVER: {Anti-pattern 1}

---

## DECISION TREES

```
{Decision point} → {Option A} if {condition} | {Option B} if {other condition}
```

---

## TECH STACK

{Framework} {version} | {Language} {version} | {Database} {version}

---

## PROJECT STRUCTURE

```
{root}/
├── {directory}/        # Description
│   └── {file}
└── AGENTS.md
```

---

## COMMANDS

```bash
# Description
{command}
```

---

## QA CHECKLIST

- [ ] {Check 1}
- [ ] {Check 2}
- [ ] All new skills have metadata.scope and metadata.auto_invoke
- [ ] AGENTS.md Auto-invoke section is up to date (run sync.sh)
