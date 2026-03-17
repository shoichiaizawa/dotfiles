---
description: Orchestrate parallel Claude Code sessions in separate git worktrees. Use when the user says "parallel", "spin up tasks", "run these in parallel", or invokes /parallel.
allowed-tools:
  - Bash(~/.claude/skills/parallel/scripts/launch.sh *)
  - Bash(~/.claude/skills/parallel/scripts/cleanup.sh *)
  - Bash(~/.claude/skills/parallel/scripts/status.sh *)
  - Bash(~/.claude/skills/parallel/scripts/merge.sh *)
  - Bash(mkdir -p ~/.claude/parallel/sessions/*)
---

# /parallel

## Context

- Task arguments: $ARGUMENTS
- Current branch: !`git branch --show-current`
- Existing worktrees: !`git worktree list`

## Instructions

### Step 0 — Read repo conventions

Before gathering tasks, learn the project's commit and coding conventions:

1. Read the project's CLAUDE.md (if it exists) for commit style, excluded files, and coding rules
2. Run `git log --oneline -5` to see recent commit message style
3. Note anything agents should know: commit format, scopes, files to avoid, coding standards

This context feeds into Step 2 — it is **not** for prescribing exact commit messages.

### Step 1 — Gather tasks

If task slugs were passed as arguments (e.g. `/parallel cleanup-bash cleanup-git`),
use them directly — skip to composing prompts for each slug.

Otherwise, ask the user to list them. For each task:
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

**Prompt structure:**
- Describe the work clearly — what to change, why, and any constraints
- Include relevant conventions discovered in Step 0 as context (e.g. "This repo
  uses Conventional Commits with scopes matching the config area. TODO.md is
  untracked — do not commit it.")
- Tell agents to commit each change atomically
- Do **not** prescribe exact commit messages, types, or scopes — let the agent
  decide based on the context provided
- Mention files that are excluded or out of scope

### Step 3 — Launch

Pass all task slugs and the prompts directory to the launch script:

```bash
~/.claude/skills/parallel/scripts/launch.sh --prompts-dir "$prompts_dir" <slug-1> <slug-2> [...]
```

The script handles everything: creates worktrees as sibling directories, launches
agents with their prompts in a new tmux window (or prints manual commands if not
in tmux), and outputs the merge plan.

### Step 4 — Monitor (optional)

Check agent progress with the status script:

```bash
~/.claude/skills/parallel/scripts/status.sh
```

It auto-discovers all `task/*` branches, checks for commits since base, and
detects open tmux panes. Pass task names to check a subset:

```bash
~/.claude/skills/parallel/scripts/status.sh <slug-1> <slug-2>
```

### Step 5 — Merge

Once agents are done, merge their branches back. The merge script handles
worktree removal, stashing, rebasing/merging, and branch cleanup in one go:

```bash
~/.claude/skills/parallel/scripts/merge.sh <slug-1> <slug-2> [...]
```

Default strategy is rebase (linear history). For merge commits:

```bash
~/.claude/skills/parallel/scripts/merge.sh --strategy merge <slug-1> <slug-2>
```

If a branch conflicts, the script aborts that branch cleanly and continues with
the rest. Resolve conflicts manually, then clean up leftovers with `cleanup.sh`.

To keep branches after merging (e.g. for further review):

```bash
~/.claude/skills/parallel/scripts/merge.sh --no-cleanup <slug-1> <slug-2>
```

## Notes

- The full lifecycle is: **launch** → **monitor** → **merge** → **cleanup** — each step has a script.
- The launch script is idempotent — it skips worktrees that already exist and panes that are already open.
- Worktree paths are siblings to the repo to avoid untracked directory noise.
- If `--prompts-dir` is omitted, agents launch with bare `claude` (no initial prompt).
- `status.sh` detects running agents by checking tmux pane directories — it may not detect agents that have exited but whose pane is still open.
- `merge.sh` handles worktree removal automatically — no need to remove them manually before merging.
- To discard all worktrees and branches without merging: `cleanup.sh <slug-1> <slug-2> ...`
- Prompt files are kept in `~/.claude/parallel/sessions/` for audit trails and re-runs.
- Set `PARALLEL_MAX_PANES` to override the default limit of 16 panes per tmux window.
