#!/usr/bin/env bash
#
# cleanup.sh — Remove worktrees and branches created by launch.sh.
#
# Usage:
#   cleanup.sh <task-name> [<task-name> ...]
#
# Example:
#   cleanup.sh add-auth fix-pagination

set -uo pipefail

# --- Resolve repo ---------------------------------------------------------

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: not inside a git repository" >&2
  exit 1
}

if [[ $# -eq 0 ]]; then
  echo "usage: cleanup.sh <task-name> [<task-name> ...]" >&2
  exit 1
fi

for task in "$@"; do
  branch="task/${task}"
  wt_path="${REPO_ROOT}-${task}"

  # Remove worktree
  if git worktree list --porcelain | grep -q "worktree ${wt_path}$"; then
    git worktree remove --force "$wt_path"
    echo "removed worktree: ${wt_path}"
  else
    echo "skip: no worktree at ${wt_path}"
  fi

  # Delete branch
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    git branch -D "$branch"
    echo "deleted branch: ${branch}"
  else
    echo "skip: no branch ${branch}"
  fi
done
