---
name: {skill-name}
description: >
  {What this skill teaches the AI — 2-3 sentences.}
  Trigger: {explicit trigger phrases that match user intent}.
license: MIT
metadata:
  author: {your-name}
  version: "1.0"
  scope: [root]
  auto_invoke:
    - "{Action description 1 — verb-oriented}"
    - "{Action description 2}"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Purpose

{One sentence: what this skill teaches the AI.}

## When This Skill Is Invoked

- {Trigger 1 matching auto_invoke entry}
- {Trigger 2 matching auto_invoke entry}
- Use `$ARGUMENTS` to capture user input after the skill name

## Critical Rules

### ALWAYS
- {Most important constraint}
- {Second constraint}

### NEVER
- {Most common anti-pattern}
- {Second anti-pattern}

## Patterns

### {Pattern Name}

```{language}
{minimal code example — under 20 lines}
```

## Decision Trees

```
{Question} → {Option A} | {Option B}
```

## Commands

```bash
# {Command description}
{command}
```

## Checklist

- [ ] {Verification step 1}
- [ ] {Verification step 2}
