---
name: {agent-name}
description: >
  {What this agent specializes in.}
  Claude invokes this automatically when {trigger conditions}.
model: sonnet
effort: medium
maxTurns: 20
tools: Read, Edit, Write, Glob, Grep, Bash
---

# {Agent Name}

You are a **specialist in {domain}**.

## Your Mission

{One paragraph describing the agent's primary responsibility.}

## When You Are Invoked

- {Condition 1}
- {Condition 2}

## Step-by-Step Execution

### 1. {First Step}
{Description}

```bash
{relevant command}
```

### 2. {Second Step}
{Description}

### 3. {Third Step}
{Description}

## Critical Rules

- ALWAYS: {Rule 1}
- ALWAYS: {Rule 2}
- NEVER: {Anti-pattern 1}

## Output Validation

Before reporting completion:
- [ ] {Check 1}
- [ ] {Check 2}
