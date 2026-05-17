#!/usr/bin/env bash
# ============================================================
# agent-config-plugin: Sync skill metadata to AGENTS.md
# Reads metadata.scope + metadata.auto_invoke from each
# skills/*/SKILL.md and updates the ### Auto-invoke Skills
# section in the corresponding AGENTS.md file(s).
#
# Usage:
#   ./sync.sh                    # Sync all scopes
#   ./sync.sh --dry-run          # Preview changes
#   ./sync.sh --scope ui         # Only sync ui scope
#   ./sync.sh --scope api        # Only sync api scope
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Navigate up: assets/ -> skill-sync/ -> skills/ -> repo root
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DRY_RUN=false
FILTER_SCOPE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)    DRY_RUN=true; shift ;;
        --scope)      FILTER_SCOPE="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [--scope <scope>]"
            echo ""
            echo "Scope values: root, ui, api, sdk, mcp_server"
            exit 0 ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1 ;;
    esac
done

# Map scope -> AGENTS.md path
get_agents_path() {
    local scope="$1"
    case "$scope" in
        root)       echo "$REPO_ROOT/AGENTS.md" ;;
        ui)         echo "$REPO_ROOT/ui/AGENTS.md" ;;
        api)        echo "$REPO_ROOT/api/AGENTS.md" ;;
        sdk)        echo "$REPO_ROOT/sdk/AGENTS.md" ;;
        mcp_server) echo "$REPO_ROOT/mcp_server/AGENTS.md" ;;
        *)          echo "" ;;
    esac
}

# Extract top-level YAML frontmatter field
extract_field() {
    local file="$1"
    local field="$2"
    awk -v field="$field" '
        /^---$/ { in_frontmatter = !in_frontmatter; next }
        in_frontmatter && $1 == field":" {
            sub(/^[^:]+:[[:space:]]*/, "")
            if ($0 != "" && $0 != ">") {
                gsub(/^["'"'"']|["'"'"']$/, "")
                print; exit
            }
            getline
            while (/^[[:space:]]/ && !/^---$/) {
                sub(/^[[:space:]]+/, "")
                printf "%s ", $0
                if (!getline) break
            }
            print ""; exit
        }
    ' "$file" | sed 's/[[:space:]]*$//'
}

# Extract metadata.{field} — supports single string or YAML list
# Returns pipe-delimited string for lists: "Action A|Action B"
extract_metadata() {
    local file="$1"
    local field="$2"

    awk -v field="$field" '
        function trim(s) {
            sub(/^[[:space:]]+/, "", s)
            sub(/[[:space:]]+$/, "", s)
            return s
        }
        /^---$/ { in_frontmatter = !in_frontmatter; next }
        in_frontmatter && /^metadata:/ { in_metadata = 1; next }
        in_frontmatter && in_metadata && /^[a-z]/ && !/^[[:space:]]/ { in_metadata = 0 }
        in_frontmatter && in_metadata && $1 == field":" {
            sub(/^[^:]+:[[:space:]]*/, "")
            if ($0 != "") {
                v = $0
                gsub(/^["'"'"']|["'"'"']$/, "", v)
                gsub(/^\[|\]$/, "", v)
                print trim(v); exit
            }
            out = ""
            while (getline) {
                if (!in_frontmatter || !in_metadata) break
                line = $0
                if (line ~ /^---$/) break
                if (line ~ /^[a-z]/ && line !~ /^[[:space:]]/) break
                if (line ~ /^[[:space:]]*-[[:space:]]*/) {
                    sub(/^[[:space:]]*-[[:space:]]*/, "", line)
                    line = trim(line)
                    gsub(/^["'"'"']|["'"'"']$/, "", line)
                    if (line != "") {
                        if (out == "") out = line
                        else out = out "|" line
                    }
                } else { break }
            }
            if (out != "") print out; exit
        }
    ' "$file"
}

echo -e "${BLUE}Agent Config — Skill Sync${NC}"
echo "=========================="
echo ""

SCOPE_TMPDIR=$(mktemp -d)
trap 'rm -rf "$SCOPE_TMPDIR"' EXIT

# Collect skills grouped by scope
while IFS= read -r skill_file; do
    [ -f "$skill_file" ] || continue

    skill_name=$(extract_field "$skill_file" "name")
    scope_raw=$(extract_metadata "$skill_file" "scope")
    auto_invoke_raw=$(extract_metadata "$skill_file" "auto_invoke")
    auto_invoke=$(echo "$auto_invoke_raw" | sed 's/|/;;/g')

    # Skip skills without required metadata
    [ -z "$scope_raw" ] || [ -z "$auto_invoke" ] && continue

    # Parse scopes (comma or space separated)
    echo "$scope_raw" | tr ', ' '\n' | while read -r scope; do
        scope=$(echo "$scope" | tr -d '[:space:][]')
        [ -z "$scope" ] && continue
        [ -n "$FILTER_SCOPE" ] && [ "$scope" != "$FILTER_SCOPE" ] && continue
        echo "$skill_name:$auto_invoke" >> "$SCOPE_TMPDIR/$scope"
    done
done < <(find "$SKILLS_DIR" -mindepth 2 -maxdepth 2 -name SKILL.md -print | sort)

# Process each scope
for scope_file in "$SCOPE_TMPDIR"/*; do
    [ -f "$scope_file" ] || continue
    scope=$(basename "$scope_file")
    agents_path=$(get_agents_path "$scope")

    if [ -z "$agents_path" ] || [ ! -f "$agents_path" ]; then
        echo -e "${YELLOW}⚠ No AGENTS.md for scope '$scope' (path: $agents_path)${NC}"
        continue
    fi

    echo -e "${BLUE}Scope: $scope → $(realpath --relative-to="$REPO_ROOT" "$agents_path" 2>/dev/null || echo "$agents_path")${NC}"

    # Build the Auto-invoke table content
    table="### Auto-invoke Skills

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|"

    rows_file=$(mktemp)

    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        skill_name="${entry%%:*}"
        actions_raw="${entry#*:}"
        actions_raw=$(echo "$actions_raw" | sed 's/;;/|/g')

        echo "$actions_raw" | tr '|' '\n' | while read -r action; do
            action=$(echo "$action" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            [ -z "$action" ] && continue
            printf "%s\t%s\n" "$action" "$skill_name" >> "$rows_file"
        done
    done < "$scope_file"

    while IFS=$'\t' read -r action skill_name; do
        [ -z "$action" ] && continue
        table="$table
| $action | \`$skill_name\` |"
    done < <(LC_ALL=C sort -t $'\t' -k1,1 -k2,2 "$rows_file")

    rm -f "$rows_file"

    if $DRY_RUN; then
        echo -e "${YELLOW}[DRY RUN] Would write:${NC}"
        echo "$table"
        echo ""
    else
        section_file=$(mktemp)
        echo "$table" > "$section_file"

        if grep -q "### Auto-invoke Skills" "$agents_path"; then
            awk '
                /^### Auto-invoke Skills/ {
                    while ((getline line < "'"$section_file"'") > 0) print line
                    close("'"$section_file"'")
                    skip = 1; next
                }
                skip && /^(---|## )/ { skip = 0; print ""; }
                !skip { print }
            ' "$agents_path" > "$agents_path.tmp"
            mv "$agents_path.tmp" "$agents_path"
            echo -e "${GREEN}  ✓ Updated Auto-invoke section${NC}"
        else
            # Insert after Skills Reference blockquote block
            awk '
                /^>.*SKILL\.md\)$/ && !inserted {
                    print
                    getline
                    if (/^$/) {
                        print ""
                        while ((getline line < "'"$section_file"'") > 0) print line
                        close("'"$section_file"'")
                        print ""; inserted = 1; next
                    }
                }
                { print }
            ' "$agents_path" > "$agents_path.tmp"
            mv "$agents_path.tmp" "$agents_path"
            echo -e "${GREEN}  ✓ Inserted Auto-invoke section${NC}"
        fi

        rm -f "$section_file"
    fi
done

echo ""
echo -e "${GREEN}Done!${NC}"

# Report skills missing metadata
echo ""
echo -e "${BLUE}Skills missing sync metadata:${NC}"
missing=0
while IFS= read -r skill_file; do
    [ -f "$skill_file" ] || continue
    skill_name=$(extract_field "$skill_file" "name")
    scope_raw=$(extract_metadata "$skill_file" "scope")
    auto_invoke_raw=$(extract_metadata "$skill_file" "auto_invoke")
    auto_invoke=$(echo "$auto_invoke_raw" | sed 's/|/;;/g')

    if [ -z "$scope_raw" ] || [ -z "$auto_invoke" ]; then
        missing_fields=""
        [ -z "$scope_raw" ]   && missing_fields="scope"
        [ -z "$auto_invoke" ] && missing_fields="$missing_fields auto_invoke"
        echo -e "  ${YELLOW}$skill_name${NC} — missing:$missing_fields"
        missing=$((missing + 1))
    fi
done < <(find "$SKILLS_DIR" -mindepth 2 -maxdepth 2 -name SKILL.md -print | sort)

if [ $missing -eq 0 ]; then
    echo -e "  ${GREEN}All skills have sync metadata ✓${NC}"
fi
