#!/usr/bin/env bash
#
# status.sh — Check progress of parallel Claude Code sessions.
#
# Usage:
#   status.sh [<task-name> ...]
#
# If no task names given, discovers all task/* branches automatically.
# Shows: commit count, worktree/pane status, files changed.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: not inside a git repository" >&2
  exit 1
}
BASE_BRANCH="$(git branch --show-current)"

# Discover tasks from arguments or from task/* branches
if [[ $# -gt 0 ]]; then
  tasks=("$@")
else
  tasks=()
  while IFS= read -r branch; do
    tasks+=("${branch#task/}")
  done < <(git for-each-ref --format='%(refname:short)' refs/heads/task/)
fi

if [[ ${#tasks[@]} -eq 0 ]]; then
  echo "no parallel tasks found"
  exit 0
fi

# Collect tmux pane directories for running detection
pane_dirs=""
if [[ -n "${TMUX:-}" ]]; then
  pane_dirs=$(tmux list-panes -s -F '#{pane_current_path}' 2>/dev/null || true)
fi

done_count=0
running_count=0
idle_count=0
missing_count=0

echo "=== Parallel Task Status ==="
echo "Base: ${BASE_BRANCH}"
echo ""

for task in "${tasks[@]}"; do
  branch="task/${task}"
  wt_path="${REPO_ROOT}-${task}"

  if ! git show-ref --verify --quiet "refs/heads/${branch}"; then
    printf "  %-12s %s — branch not found\n" "MISSING" "$task"
    missing_count=$((missing_count + 1))
    continue
  fi

  commits=$(git log --oneline "${BASE_BRANCH}..${branch}" 2>/dev/null | wc -l | tr -d ' ')

  # Detect pane open for this worktree
  pane_open=false
  if [[ -n "$pane_dirs" ]] && echo "$pane_dirs" | grep -qxF "$wt_path"; then
    pane_open=true
  fi

  if $pane_open; then
    status="RUNNING"
    running_count=$((running_count + 1))
  elif [[ "$commits" -gt 0 ]]; then
    status="DONE"
    done_count=$((done_count + 1))
  else
    status="IDLE"
    idle_count=$((idle_count + 1))
  fi

  printf "  %-12s %-24s %s commit(s)\n" "$status" "$task" "$commits"

  if [[ "$commits" -gt 0 ]]; then
    files=$(git diff --stat "${BASE_BRANCH}..${branch}" 2>/dev/null | tail -1)
    if [[ -n "$files" ]]; then
      echo "             $files"
    fi
  fi
done

echo ""
echo "=== Summary ==="
total=${#tasks[@]}
echo "${done_count} done, ${running_count} running, ${idle_count} idle, ${missing_count} missing (${total} total)"
