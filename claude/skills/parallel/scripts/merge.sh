#!/usr/bin/env bash
#
# merge.sh — Merge completed task branches back to base.
#
# Usage:
#   merge.sh [--strategy rebase|merge] [--no-cleanup] <task-name> [<task-name> ...]
#
# Options:
#   --strategy rebase   Rebase then fast-forward (linear history, default)
#   --strategy merge    Merge commit per branch
#   --no-cleanup        Keep branches after merging (default: delete merged branches)
#
# Safety:
#   - Stashes dirty working tree before starting, restores after
#   - Removes worktrees before rebasing (rebase refuses checked-out branches)
#   - Aborts cleanly on conflict — reports which tasks failed
#
# Example:
#   merge.sh add-auth fix-pagination
#   merge.sh --strategy merge --no-cleanup refactor-api

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: not inside a git repository" >&2
  exit 1
}
BASE_BRANCH="$(git branch --show-current)"

STRATEGY="rebase"
CLEANUP=true

while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --strategy)
      STRATEGY="$2"; shift 2 ;;
    --no-cleanup)
      CLEANUP=false; shift ;;
    *)
      echo "error: unknown option '$1'" >&2
      echo "usage: merge.sh [--strategy rebase|merge] [--no-cleanup] <task-name> [...]" >&2
      exit 1
      ;;
  esac
done

if [[ $# -eq 0 ]]; then
  echo "usage: merge.sh [--strategy rebase|merge] [--no-cleanup] <task-name> [...]" >&2
  exit 1
fi

if [[ "$STRATEGY" != "rebase" && "$STRATEGY" != "merge" ]]; then
  echo "error: strategy must be 'rebase' or 'merge'" >&2
  exit 1
fi

# --- Safety: clean working tree -------------------------------------------

STASHED=false
if [[ -n "$(git status --porcelain)" ]]; then
  echo "stashing dirty working tree"
  git stash
  STASHED=true
fi

# --- Review ---------------------------------------------------------------

echo "=== Merge Plan (${STRATEGY}) ==="
echo ""

valid_tasks=()
for task in "$@"; do
  branch="task/${task}"

  if ! git show-ref --verify --quiet "refs/heads/${branch}"; then
    echo "skip: branch '${branch}' not found"
    continue
  fi

  valid_tasks+=("$task")
  commits=$(git log --oneline "${BASE_BRANCH}..${branch}" 2>/dev/null)
  count=$(echo "$commits" | grep -c . 2>/dev/null || echo 0)

  echo "## ${task} (${count} commit(s))"
  echo "$commits" | sed 's/^/  /'
  echo ""
done

if [[ ${#valid_tasks[@]} -eq 0 ]]; then
  echo "no valid branches to merge"
  if $STASHED; then git stash pop; fi
  exit 1
fi

# --- Remove worktrees -----------------------------------------------------
# rebase can't operate on branches checked out in a worktree

echo "=== Removing worktrees ==="
for task in "${valid_tasks[@]}"; do
  wt_path="${REPO_ROOT}-${task}"
  if git worktree list --porcelain | grep -q "worktree ${wt_path}$"; then
    if git worktree remove --force "$wt_path" 2>/dev/null; then
      echo "removed: ${wt_path}"
    else
      echo "error: could not remove ${wt_path}" >&2
    fi
  fi
done
echo ""

# --- Merge ----------------------------------------------------------------

echo "=== Merging ==="
merged=()
failed=()

for task in "${valid_tasks[@]}"; do
  branch="task/${task}"
  echo "merging ${task}..."

  if [[ "$STRATEGY" == "rebase" ]]; then
    if git rebase "${BASE_BRANCH}" "${branch}" 2>&1 | sed 's/^/  /' && \
       git checkout "${BASE_BRANCH}" 2>/dev/null && \
       git merge --ff-only "${branch}" 2>/dev/null; then
      echo "  ok: fast-forward merged"
      merged+=("$task")
    else
      echo "  CONFLICT — aborting rebase for ${task}" >&2
      git rebase --abort 2>/dev/null
      git checkout "${BASE_BRANCH}" 2>/dev/null
      failed+=("$task")
    fi
  else
    if git merge --no-ff -m "Merge task/${task}" "${branch}" 2>&1 | sed 's/^/  /'; then
      echo "  ok: merge commit created"
      merged+=("$task")
    else
      echo "  CONFLICT — aborting merge for ${task}" >&2
      git merge --abort 2>/dev/null
      failed+=("$task")
    fi
  fi
  echo ""
done

# --- Cleanup merged branches ----------------------------------------------

if $CLEANUP && [[ ${#merged[@]} -gt 0 ]]; then
  echo "=== Cleanup ==="
  for task in "${merged[@]}"; do
    branch="task/${task}"
    if git branch -d "$branch" 2>/dev/null; then
      echo "deleted: ${branch}"
    fi
  done
  echo ""
fi

# --- Restore stash --------------------------------------------------------

if $STASHED; then
  echo "restoring stashed changes"
  git stash pop
fi

# --- Summary --------------------------------------------------------------

echo "=== Result ==="
echo "${#merged[@]} merged, ${#failed[@]} failed"
if [[ ${#failed[@]} -gt 0 ]]; then
  echo "failed: ${failed[*]}"
  echo "resolve conflicts manually, then clean up with:"
  echo "  ~/.claude/skills/parallel/scripts/cleanup.sh ${failed[*]}"
fi
