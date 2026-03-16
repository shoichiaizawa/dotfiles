#!/usr/bin/env bash
#
# cleanup.sh — Remove worktrees and branches created by launch.sh.
#
# Usage:
#   cleanup.sh [--dry-run] [--force] <task-name> [<task-name> ...]
#
# Options:
#   --dry-run  Show what would be removed without doing it
#   --force    Use git branch -D (delete even with unmerged commits)
#
# Example:
#   cleanup.sh add-auth fix-pagination

set -uo pipefail

# --- Resolve repo ---------------------------------------------------------

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: not inside a git repository" >&2
  exit 1
}
BASE_BRANCH="$(git branch --show-current)"

DRY_RUN=false
FORCE=false

while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --force)   FORCE=true; shift ;;
    *)
      echo "error: unknown option '$1'" >&2
      echo "usage: cleanup.sh [--dry-run] [--force] <task-name> [<task-name> ...]" >&2
      exit 1
      ;;
  esac
done

if [[ $# -eq 0 ]]; then
  echo "usage: cleanup.sh [--dry-run] [--force] <task-name> [<task-name> ...]" >&2
  exit 1
fi

for task in "$@"; do
  branch="task/${task}"
  wt_path="${REPO_ROOT}-${task}"

  # Remove worktree
  if git worktree list --porcelain | grep -q "worktree ${wt_path}$"; then
    if $DRY_RUN; then
      echo "would remove worktree: ${wt_path}"
    elif git worktree remove --force "$wt_path"; then
      echo "removed worktree: ${wt_path}"
    else
      echo "error: failed to remove worktree ${wt_path}" >&2
    fi
  else
    echo "skip: no worktree at ${wt_path}"
  fi

  # Delete branch
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    # Check for unmerged commits
    unmerged=$(git log --oneline "${BASE_BRANCH}..${branch}" 2>/dev/null)

    if [[ -n "$unmerged" ]] && ! $FORCE; then
      echo "warning: branch '${branch}' has unmerged commits:" >&2
      echo "$unmerged" | sed 's/^/  /' >&2

      if [[ -t 0 ]] && ! $DRY_RUN; then
        printf "delete anyway? [y/N] " >&2
        read -r answer
        if [[ "$answer" != [yY] ]]; then
          echo "skip: kept branch ${branch}"
          continue
        fi
        # User confirmed — force-delete since -d would refuse
        git branch -D "$branch"
        echo "deleted branch: ${branch}"
      else
        echo "skip: run with --force to delete, or merge first" >&2
      fi
      continue
    fi

    if $DRY_RUN; then
      echo "would delete branch: ${branch}"
    else
      if $FORCE; then
        git branch -D "$branch"
      else
        git branch -d "$branch"
      fi
      echo "deleted branch: ${branch}"
    fi
  else
    echo "skip: no branch ${branch}"
  fi
done
