#!/bin/bash
# ============================================================
# agent-config-plugin: Setup AI Skills for any project
# Follows the agentskills.io standard (Prowler pattern)
#
# Configures AI coding assistants by creating symlinks and
# copying AGENTS.md files to the expected locations:
#   - Claude Code:     .claude/skills/ symlink + CLAUDE.md copies
#   - Gemini CLI:      .gemini/skills/ symlink + GEMINI.md copies
#   - Codex (OpenAI):  .codex/skills/  symlink + AGENTS.md (native)
#   - GitHub Copilot:  .github/copilot-instructions.md copy
#
# Usage:
#   ./skills/setup.sh              # Interactive mode
#   ./skills/setup.sh --all        # Configure all AI assistants
#   ./skills/setup.sh --claude     # Configure only Claude Code
#   ./skills/setup.sh --claude --codex  # Multiple assistants
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_SOURCE="$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Selection flags
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_CODEX=false
SETUP_COPILOT=false

# ============================================================
# HELPER FUNCTIONS
# ============================================================

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Configure AI coding assistants for agent/sub-agent development."
    echo ""
    echo "Options:"
    echo "  --all       Configure all AI assistants"
    echo "  --claude    Configure Claude Code"
    echo "  --gemini    Configure Gemini CLI"
    echo "  --codex     Configure Codex (OpenAI)"
    echo "  --copilot   Configure GitHub Copilot"
    echo "  --help      Show this help message"
    echo ""
    echo "If no options provided, runs in interactive mode."
    echo ""
    echo "Examples:"
    echo "  $0                    # Interactive selection"
    echo "  $0 --all              # All AI assistants"
    echo "  $0 --claude --codex   # Only Claude and Codex"
}

show_menu() {
    echo -e "${BOLD}Which AI assistants do you use?${NC}"
    echo -e "${CYAN}(Use numbers to toggle, Enter to confirm)${NC}"
    echo ""

    local options=("Claude Code" "Gemini CLI" "Codex (OpenAI)" "GitHub Copilot")
    local selected=(true false false false)  # Claude selected by default

    while true; do
        for i in "${!options[@]}"; do
            if [ "${selected[$i]}" = true ]; then
                echo -e "  ${GREEN}[x]${NC} $((i+1)). ${options[$i]}"
            else
                echo -e "  [ ] $((i+1)). ${options[$i]}"
            fi
        done
        echo ""
        echo -e "  ${YELLOW}a${NC}. Select all"
        echo -e "  ${YELLOW}n${NC}. Select none"
        echo ""
        echo -n "Toggle (1-4, a, n) or Enter to confirm: "

        read -r choice

        case $choice in
            1) selected[0]=$([ "${selected[0]}" = true ] && echo false || echo true) ;;
            2) selected[1]=$([ "${selected[1]}" = true ] && echo false || echo true) ;;
            3) selected[2]=$([ "${selected[2]}" = true ] && echo false || echo true) ;;
            4) selected[3]=$([ "${selected[3]}" = true ] && echo false || echo true) ;;
            a|A) selected=(true true true true) ;;
            n|N) selected=(false false false false) ;;
            "") break ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac

        # Redraw menu
        echo -en "\033[10A\033[J"
    done

    SETUP_CLAUDE=${selected[0]}
    SETUP_GEMINI=${selected[1]}
    SETUP_CODEX=${selected[2]}
    SETUP_COPILOT=${selected[3]}
}

make_symlink() {
    local target_dir="$1"
    local target="$target_dir/skills"

    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        mv "$target" "$target_dir/skills.backup.$(date +%s)"
        echo -e "${YELLOW}  ⚠ Existing skills/ backed up${NC}"
    fi

    ln -s "$SKILLS_SOURCE" "$target"
}

# Create a symlink safely (removes old link/file, never overwrites)
make_file_symlink() {
    local src="$1"   # absolute path to source file
    local link="$2"  # absolute path where symlink should live

    if [ -L "$link" ]; then
        rm "$link"
    elif [ -f "$link" ]; then
        mv "$link" "${link}.backup.$(date +%s)"
        echo -e "${YELLOW}  ⚠ Existing $(basename "$link") backed up${NC}"
    fi

    ln -s "$src" "$link"
}

setup_claude() {
    # 1. .claude/skills/ symlink → skills/  (skill auto-discovery)
    make_symlink "$REPO_ROOT/.claude"
    echo -e "${GREEN}  ✓ .claude/skills -> skills/${NC}"

    # 2. .claude.md → AGENTS.md symlink (Blueprint §5 — source-of-truth, no copy)
    #    Propagated for EVERY scope that has an AGENTS.md
    local agents_files count=0
    agents_files=$(find "$REPO_ROOT" -name "AGENTS.md" \
        -not -path "*/node_modules/*" \
        -not -path "*/.git/*" \
        -not -path "*/skills/*" \
        2>/dev/null)

    for agents_file in $agents_files; do
        local dir
        dir=$(dirname "$agents_file")
        make_file_symlink "$agents_file" "$dir/.claude.md"
        count=$((count + 1))
    done

    echo -e "${GREEN}  ✓ Created $count .claude.md -> AGENTS.md symlink(s)${NC}"
}

setup_gemini() {
    make_symlink "$REPO_ROOT/.gemini"
    echo -e "${GREEN}  ✓ .gemini/skills -> skills/${NC}"

    # Gemini reads GEMINI.md — keep as copy (Gemini has no symlink convention)
    copy_agents_md "GEMINI.md"
}

setup_codex() {
    make_symlink "$REPO_ROOT/.codex"
    echo -e "${GREEN}  ✓ .codex/skills -> skills/${NC}"
    echo -e "${GREEN}  ✓ Codex reads AGENTS.md natively (no extra file needed)${NC}"
}

setup_copilot() {
    if [ -f "$REPO_ROOT/AGENTS.md" ]; then
        mkdir -p "$REPO_ROOT/.github"
        cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.github/copilot-instructions.md"
        echo -e "${GREEN}  ✓ AGENTS.md -> .github/copilot-instructions.md${NC}"
    else
        echo -e "${YELLOW}  ⚠ No root AGENTS.md found — skipping Copilot setup${NC}"
    fi
}

copy_agents_md() {
    local target_name="$1"
    local agents_files
    local count=0

    agents_files=$(find "$REPO_ROOT" -name "AGENTS.md" \
        -not -path "*/node_modules/*" \
        -not -path "*/.git/*" \
        -not -path "*/skills/*" \
        2>/dev/null)

    for agents_file in $agents_files; do
        local agents_dir
        agents_dir=$(dirname "$agents_file")
        cp "$agents_file" "$agents_dir/$target_name"
        count=$((count + 1))
    done

    echo -e "${GREEN}  ✓ Copied $count AGENTS.md -> $target_name${NC}"
}

# ============================================================
# PARSE ARGUMENTS
# ============================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            SETUP_CLAUDE=true; SETUP_GEMINI=true
            SETUP_CODEX=true;  SETUP_COPILOT=true
            shift ;;
        --claude)  SETUP_CLAUDE=true;  shift ;;
        --gemini)  SETUP_GEMINI=true;  shift ;;
        --codex)   SETUP_CODEX=true;   shift ;;
        --copilot) SETUP_COPILOT=true; shift ;;
        --help|-h) show_help; exit 0 ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help; exit 1 ;;
    esac
done

# ============================================================
# MAIN
# ============================================================

echo "🤖 Agent Config — AI Skills Setup"
echo "==================================="
echo ""

SKILL_COUNT=$(find "$SKILLS_SOURCE" -maxdepth 2 -name "SKILL.md" | wc -l | tr -d ' ')

if [ "$SKILL_COUNT" -eq 0 ]; then
    echo -e "${RED}No skills found in $SKILLS_SOURCE${NC}"
    echo "Run /agent-config:agent-scaffold first to generate skills."
    exit 1
fi

echo -e "${BLUE}Found $SKILL_COUNT skills in skills/${NC}"
echo ""

# Interactive mode if no flags
if [ "$SETUP_CLAUDE" = false ] && [ "$SETUP_GEMINI" = false ] && \
   [ "$SETUP_CODEX" = false ] && [ "$SETUP_COPILOT" = false ]; then
    show_menu
    echo ""
fi

# Nothing selected
if [ "$SETUP_CLAUDE" = false ] && [ "$SETUP_GEMINI" = false ] && \
   [ "$SETUP_CODEX" = false ] && [ "$SETUP_COPILOT" = false ]; then
    echo -e "${YELLOW}No AI assistants selected. Nothing to do.${NC}"
    exit 0
fi

# Count total steps
STEP=1; TOTAL=0
[ "$SETUP_CLAUDE"  = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_GEMINI"  = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_CODEX"   = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_COPILOT" = true ] && TOTAL=$((TOTAL + 1))

[ "$SETUP_CLAUDE" = true ] && {
    echo -e "${YELLOW}[$STEP/$TOTAL] Setting up Claude Code...${NC}"
    setup_claude; STEP=$((STEP + 1))
}

[ "$SETUP_GEMINI" = true ] && {
    echo -e "${YELLOW}[$STEP/$TOTAL] Setting up Gemini CLI...${NC}"
    setup_gemini; STEP=$((STEP + 1))
}

[ "$SETUP_CODEX" = true ] && {
    echo -e "${YELLOW}[$STEP/$TOTAL] Setting up Codex (OpenAI)...${NC}"
    setup_codex; STEP=$((STEP + 1))
}

[ "$SETUP_COPILOT" = true ] && {
    echo -e "${YELLOW}[$STEP/$TOTAL] Setting up GitHub Copilot...${NC}"
    setup_copilot
}

# ============================================================
# SUMMARY
# ============================================================

echo ""
echo -e "${GREEN}✅ Successfully configured $SKILL_COUNT AI skills!${NC}"
echo ""
echo "Configured:"
[ "$SETUP_CLAUDE"  = true ] && echo "  • Claude Code:    .claude/skills/ (skill discovery) + .claude.md -> AGENTS.md (symlink)"
[ "$SETUP_CODEX"   = true ] && echo "  • Codex (OpenAI): .codex/skills/   + AGENTS.md (native)"
[ "$SETUP_GEMINI"  = true ] && echo "  • Gemini CLI:     .gemini/skills/  + GEMINI.md"
[ "$SETUP_COPILOT" = true ] && echo "  • GitHub Copilot: .github/copilot-instructions.md"
echo ""
echo -e "${BLUE}Tip: Restart your AI assistant to reload skills.${NC}"
echo -e "${BLUE}Note: AGENTS.md is the source of truth — edit it, then re-run this script.${NC}"
echo -e "${BLUE}Sync: ./skills/skill-sync/assets/sync.sh --dry-run${NC}"
