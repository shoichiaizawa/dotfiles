#!/usr/bin/env bash
# Read the effortLevel label from Claude Code settings.
# Checks project-level first, then global, and outputs the label.
#
# Usage: effort-level.sh
# Output: the effort label (e.g., low, medium, high, auto) or N/A

set -euo pipefail

extract_effort() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Extract effortLevel value using python3 for reliable JSON parsing
        python3 -c "
import json, sys
try:
    with open('$file') as f:
        d = json.load(f)
    v = d.get('effortLevel')
    if v:
        print(v)
        sys.exit(0)
except Exception:
    pass
sys.exit(1)
" 2>/dev/null && return 0
    fi
    return 1
}

# Project-level takes precedence
project_settings=".claude/settings.json"
global_settings="$HOME/.claude/settings.json"

effort=$(extract_effort "$project_settings") && { echo "$effort"; exit 0; }
effort=$(extract_effort "$global_settings") && { echo "$effort"; exit 0; }

echo "N/A"
