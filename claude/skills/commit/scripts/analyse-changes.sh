#!/usr/bin/env bash
# Analyse working tree changes for atomicity assessment.
# Groups changed files by directory and flags multi-area changes.
#
# Usage: analyse-changes.sh
# Output: structured summary suitable for LLM consumption

set -euo pipefail

# Collect changed file paths
staged=$(git diff --cached --name-only 2>/dev/null || true)
unstaged=$(git diff --name-only 2>/dev/null || true)
untracked=$(git ls-files --others --exclude-standard 2>/dev/null || true)

all_changed=$(printf '%s\n%s\n%s' "$staged" "$unstaged" "$untracked" | sort -u | grep -v '^$' || true)

if [[ -z "$all_changed" ]]; then
    echo "No changes detected."
    exit 0
fi

echo "=== Changed Files ==="

if [[ -n "$staged" ]]; then
    echo ""
    echo "## Staged"
    git diff --cached --stat | sed '$d'
fi

if [[ -n "$unstaged" ]]; then
    echo ""
    echo "## Unstaged"
    git diff --stat | sed '$d'
fi

if [[ -n "$untracked" ]]; then
    echo ""
    echo "## Untracked"
    echo "$untracked" | sed 's/^/  ? /'
fi

# Group by second-level path (e.g. claude/skills, scripts/deploy)
echo ""
echo "=== Directory Groups ==="
echo "$all_changed" | awk -F'/' '{
    if (NF >= 2) print $1 "/" $2
    else print $1
}' | sort | uniq -c | sort -rn | while read -r count dir; do
    printf "  %d file(s) in %s\n" "$count" "$dir"
done

# Count distinct top-level directories
top_dirs=$(echo "$all_changed" | awk -F'/' '{print $1}' | sort -u | wc -l | tr -d ' ')

echo ""
echo "=== Atomicity Signal ==="
if [[ "$top_dirs" -gt 2 ]]; then
    echo "SPLIT-LIKELY: changes span $top_dirs top-level directories"
elif [[ "$top_dirs" -gt 1 ]]; then
    echo "REVIEW: changes span $top_dirs top-level directories"
else
    echo "OK: changes confined to a single area"
fi
