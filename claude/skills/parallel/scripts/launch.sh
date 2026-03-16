#!/usr/bin/env bash
#
# launch.sh — Create worktrees and launch parallel Claude Code sessions.
#
# Usage:
#   launch.sh [--prompts-dir <dir>] <task-name> [<task-name> ...]
#
# Example:
#   launch.sh --prompts-dir /tmp/parallel-abc add-auth fix-pagination
#
# Each task name becomes:
#   - Branch:   task/<task-name>
#   - Worktree: <repo-root>-<task-name>  (sibling directory)
#
# If inside tmux, opens a new window with one pane per agent.
# If not, prints the commands to run manually.

set -uo pipefail

# --- Resolve repo ---------------------------------------------------------

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: not inside a git repository" >&2
  exit 1
}
BASE_BRANCH="$(git branch --show-current)"

# Optional: directory containing <slug>.md prompt files
PROMPTS_DIR=""
if [[ "${1:-}" == "--prompts-dir" ]]; then
  PROMPTS_DIR="$2"
  shift 2
fi

if [[ $# -eq 0 ]]; then
  echo "usage: launch.sh [--prompts-dir <dir>] <task-name> [<task-name> ...]" >&2
  exit 1
fi

# --- Validate task names ---------------------------------------------------

for task in "$@"; do
  if [[ ! "$task" =~ ^[a-z0-9-]+$ ]]; then
    echo "error: invalid task name '${task}' — only lowercase letters, digits, and hyphens allowed" >&2
    exit 1
  fi
done

if [[ $# -eq 1 ]]; then
  echo "hint: only 1 task — consider 'claude --worktree' instead"
  echo "      proceeding anyway..."
  echo ""
fi

# Max panes per window — override with PARALLEL_MAX_PANES
MAX_PANES="${PARALLEL_MAX_PANES:-16}"

# --- Create worktrees (if needed) ------------------------------------------
# Ensures worktrees exist. Panes are opened for all valid entries.

branches=()
paths=()
names=()
skipped=0

for task in "$@"; do
  branch="task/${task}"
  wt_path="${REPO_ROOT}-${task}"

  if git worktree list --porcelain | grep -q "worktree ${wt_path}$"; then
    echo "ok: worktree exists at ${wt_path}"
    branches+=("$branch")
    paths+=("$wt_path")
    names+=("$task")
  elif git show-ref --verify --quiet "refs/heads/${branch}"; then
    echo "error: branch '${branch}' already exists (not as a worktree)" >&2
    echo "  hint: delete it with 'git branch -d ${branch}' or use a different task name" >&2
    skipped=$((skipped + 1))
  elif git worktree add -b "$branch" "$wt_path"; then
    branches+=("$branch")
    paths+=("$wt_path")
    names+=("$task")
  else
    echo "error: failed to create worktree for ${task}" >&2
    skipped=$((skipped + 1))
  fi
done

if [[ $skipped -gt 0 ]]; then
  echo ""
  echo "warning: ${skipped} task(s) skipped due to errors" >&2
fi

if [[ ${#paths[@]} -eq 0 ]]; then
  echo "error: no worktrees available" >&2
  exit 1
fi

echo ""
git worktree list
echo ""

# --- Print merge plan (before tmux, so it always appears) ------------------

echo "# ── review (run from ${REPO_ROOT}) ──"
echo ""

for i in "${!names[@]}"; do
  echo "# ${names[$i]}"
  echo "git log --oneline ${BASE_BRANCH}..${branches[$i]}"
  echo "git diff ${BASE_BRANCH}..${branches[$i]}"
  echo ""
done

echo "# ── prerequisites (before merging) ──"
echo ""
echo "# stash or commit local changes first"
echo "git stash"
echo ""
echo "# remove worktrees — rebase can't operate on checked-out branches"
for i in "${!paths[@]}"; do
  echo "git worktree remove ${paths[$i]}"
done
echo ""

echo "# ── merge plan: rebase (linear history) ──"
echo ""
for i in "${!branches[@]}"; do
  echo "git rebase ${BASE_BRANCH} ${branches[$i]}"
  echo "git checkout ${BASE_BRANCH}"
  echo "git merge --ff-only ${branches[$i]}"
  echo ""
done

echo "# ── merge plan: merge (merge commit) ──"
echo ""
for i in "${!branches[@]}"; do
  echo "git merge ${branches[$i]}"
done

echo ""
echo "# ── cleanup ──"
echo ""
echo "~/.claude/skills/parallel/scripts/cleanup.sh ${names[*]}"
echo ""

# --- Deduplicate panes ----------------------------------------------------
# Skip worktree paths that already have a pane open in this tmux session.

launch_paths=()
launch_names=()

if [[ -n "${TMUX:-}" ]]; then
  existing_pane_dirs=$(tmux list-panes -s -F '#{pane_current_path}' 2>/dev/null)
  for i in "${!paths[@]}"; do
    if echo "$existing_pane_dirs" | grep -qxF "${paths[$i]}"; then
      echo "skip: pane already open for ${names[$i]}"
    else
      launch_paths+=("${paths[$i]}")
      launch_names+=("${names[$i]}")
    fi
  done
else
  launch_paths=("${paths[@]}")
  launch_names=("${names[@]}")
fi

if [[ ${#launch_paths[@]} -eq 0 ]]; then
  echo "all tasks already have panes open"
  exit 0
fi

# --- Launch agents ---------------------------------------------------------

# Build a shell-safe claude command for a task.
# Uses printf '%q' to escape prompt content so $, `, ", \ in prompts
# are not interpreted by the pane's shell.
build_claude_cmd() {
  local task="$1"
  if [[ -n "$PROMPTS_DIR" && -f "${PROMPTS_DIR}/${task}.md" ]]; then
    local escaped
    escaped=$(printf '%q' "$(cat "${PROMPTS_DIR}/${task}.md")")
    echo "claude ${escaped}"
  else
    echo "claude"
  fi
}

if [[ -z "${TMUX:-}" ]]; then
  echo "not inside tmux — run these manually:"
  echo ""
  for i in "${!launch_paths[@]}"; do
    p="${launch_paths[$i]}"
    task="${launch_names[$i]}"
    claude_cmd=$(build_claude_cmd "$task")
    echo "  cd ${p} && ${claude_cmd}"
  done
  exit 0
fi

next_unique_win() {
  local base="$1" name="$1" n=0
  while tmux list-windows -F '#W' 2>/dev/null | grep -q "^${name}$"; do
    n=$((n + 1))
    name="${base}-${n}"
  done
  echo "$name"
}

# Find an existing parallel window with room for more panes
find_existing_win() {
  local win panes
  for win in $(tmux list-windows -F '#W' 2>/dev/null | grep '^parallel'); do
    panes=$(tmux list-panes -t "$win" 2>/dev/null | wc -l | tr -d ' ')
    if [[ $panes -lt $MAX_PANES ]]; then
      echo "$win $panes"
      return 0
    fi
  done
  return 1
}

total=${#launch_paths[@]}
current_win=""
pane_in_win=0
windows_used=()

# Try to reuse an existing parallel window first
if existing=$(find_existing_win); then
  current_win="${existing% *}"
  pane_in_win="${existing#* }"
  windows_used+=("$current_win")
fi

for i in "${!launch_paths[@]}"; do
  p="${launch_paths[$i]}"
  task="${launch_names[$i]}"
  claude_cmd=$(build_claude_cmd "$task")

  if [[ -z "$current_win" ]] || [[ $pane_in_win -ge $MAX_PANES ]]; then
    # Need a new window
    current_win="$(next_unique_win "parallel")"
    windows_used+=("$current_win")
    pane_id=$(tmux new-window -d -n "$current_win" -c "$p" -P -F '#{pane_id}')
    tmux send-keys -t "$pane_id" "$claude_cmd" Enter
    pane_in_win=1
  else
    # Add to existing window
    pane_id=$(tmux split-window -d -h -t "$current_win" -c "$p" -P -F '#{pane_id}')
    tmux send-keys -t "$pane_id" "$claude_cmd" Enter
    if [[ $pane_in_win -ge 2 ]]; then
      tmux select-layout -t "$current_win" tiled 2>/dev/null || true
    fi
    pane_in_win=$((pane_in_win + 1))
  fi
done

# Deduplicate window names for the summary
unique_wins=($(printf '%s\n' "${windows_used[@]}" | awk '!seen[$0]++'))
if [[ ${#unique_wins[@]} -eq 1 ]]; then
  echo "launched ${total} agents in tmux window '${unique_wins[0]}'"
else
  echo "launched ${total} agents across ${#unique_wins[@]} windows: ${unique_wins[*]}"
fi
