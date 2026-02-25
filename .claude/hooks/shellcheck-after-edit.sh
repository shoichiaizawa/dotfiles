#!/usr/bin/env bash
# Hook: shellcheck-after-edit.sh — PostToolUse hook for Claude Code
# Runs bash -n (syntax check) and shellcheck on shell files after Edit/Write operations.
# Receives hook input as JSON on stdin.

set -euo pipefail

# Parse the file path from hook input JSON
file_path=$(jq -r '.tool_input.file_path // .tool_input.command // empty' 2>/dev/null)

# Exit silently if no file path
[[ -z "${file_path:-}" ]] && exit 0

# Only check known shell files in this repo
case "$file_path" in
  */bash/*|*/macos|*/tmux/bin/*|*/welcome.sh)
    ;;
  *)
    exit 0
    ;;
esac

# Exit silently if the file doesn't exist
[[ -f "$file_path" ]] || exit 0

# Run bash -n syntax check (non-blocking — informational only)
output=$(bash -n "$file_path" 2>&1) || true
if [[ -n "$output" ]]; then
  echo "bash -n syntax errors in $(basename "$file_path"):"
  echo "$output"
fi

# Run shellcheck (non-blocking — informational only)
if command -v shellcheck &>/dev/null; then
  output=$(shellcheck --severity=warning --shell=bash "$file_path" 2>&1) || true
  if [[ -n "$output" ]]; then
    echo "shellcheck findings for $(basename "$file_path"):"
    echo "$output"
  fi
fi
