---
description: Orchestrate parallel Claude Code sessions in separate git worktrees. Use when the user says "parallel", "spin up tasks", "run these in parallel", or invokes /parallel.
allowed-tools:
  - Bash(~/.claude/skills/parallel/scripts/launch.sh *)
  - Bash(~/.claude/skills/parallel/scripts/cleanup.sh *)
  - Bash(mkdir -p ~/.claude/parallel/sessions/*)
---

# /parallel

## Context

- Current branch: !`git branch --show-current`
- Existing worktrees: !`git worktree list`

## Instructions

### Step 1 — Gather tasks

If tasks are not already provided, ask the user to list them. For each task:
- Derive a short slug (lowercase, hyphens, no spaces) — e.g., `add-auth`, `fix-pagination`
- Capture or compose a clear, self-contained prompt describing what the agent should do

If the user provides only one task, suggest `claude --worktree` as a simpler
alternative. Proceed with the script if they still want `/parallel`.

### Step 2 — Write prompt files

Create a session directory and write one prompt file per task:

```bash
prompts_dir="$HOME/.claude/parallel/sessions/$(date +%Y-%m-%dT%H-%M-%S)"
mkdir -p "$prompts_dir"
```

For each task, use the Write tool to create `<prompts_dir>/<slug>.md` containing
the agent's prompt. Each prompt should be actionable and self-contained — the
agent won't have the original conversation context.

### Step 3 — Launch

Pass all task slugs and the prompts directory to the launch script:

```bash
~/.claude/skills/parallel/scripts/launch.sh --prompts-dir "$prompts_dir" <slug-1> <slug-2> [...]
```

The script handles everything: creates worktrees as sibling directories, launches
agents with their prompts in a new tmux window (or prints manual commands if not
in tmux), and outputs the merge plan.

### Step 4 — Relay output

Show the user the script's output. The merge plan at the bottom is what they run
after the agents finish — do not execute it.

## Notes

- This skill creates worktrees and launches agents. It does NOT create issues, detect conflicts, or merge branches.
- The launch script is idempotent — it skips worktrees that already exist and panes that are already open.
- Worktree paths are siblings to the repo to avoid untracked directory noise.
- If `--prompts-dir` is omitted, agents launch with bare `claude` (no initial prompt).
- The merge plan shows both rebase (linear history) and merge (merge commit) options — the user picks whichever fits the project.
- To discard all worktrees and branches: `cleanup.sh <slug-1> <slug-2> ...`
- Prompt files are kept in `~/.claude/parallel/sessions/` for audit trails and re-runs.
