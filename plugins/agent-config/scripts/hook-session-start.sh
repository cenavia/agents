#!/usr/bin/env bash
# SessionStart hook — fires when a Claude Code session begins
# Prints a one-line reminder about agent-config commands
#
# Called by: hooks/hooks.json → SessionStart

set -e

# Only print if the project has been scaffolded (sync.sh exists)
if [ -f "./skills/skill-sync/assets/sync.sh" ]; then
    echo "[agent-config] Agent config active — skills: /agent-config:agent-scaffold | /agent-config:skill-designer | /agent-config:agents-sync"
fi
