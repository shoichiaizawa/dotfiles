#!/usr/bin/env bash
# Pre-flight check for /commit skill.
# Detects whether the current directory is inside a git repository.
#
# Output signals:
#   REPO_OK          — inside a git work tree, proceed normally
#   NOT_A_GIT_REPO   — no git repository found

set -euo pipefail

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "REPO_OK"
else
    echo "NOT_A_GIT_REPO"
fi
