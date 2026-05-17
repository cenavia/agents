#!/usr/bin/env bash
# PostToolUse hook — fires after Write/Edit operations
# Reminds the user to run sync.sh when a SKILL.md is modified
#
# Called by: hooks/hooks.json → PostToolUse → Write|Edit matcher
# Env vars available: CLAUDE_TOOL_NAME, CLAUDE_TOOL_INPUT, CLAUDE_TOOL_OUTPUT

set -e

# Check if the written/edited file is a SKILL.md
tool_input="${CLAUDE_TOOL_INPUT:-}"
tool_output="${CLAUDE_TOOL_OUTPUT:-}"

if echo "$tool_input$tool_output" | grep -q "SKILL\.md"; then
    echo "[agent-config] ⚠  SKILL.md modified — sync AGENTS.md Auto-invoke tables:"
    echo "               Run: ./skills/skill-sync/assets/sync.sh"
    echo "               Or:  ./skills/skill-sync/assets/sync.sh --dry-run"
fi
