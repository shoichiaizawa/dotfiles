---
description: Orchestrate parallel Claude Code sessions in separate git worktrees. Use when the user says "parallel", "spin up tasks", "run these in parallel", or invokes /parallel.
allowed-tools:
  - Bash(~/.claude/skills/parallel/scripts/launch.sh *)
  - Bash(~/.claude/skills/parallel/scripts/cleanup.sh *)
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

### Step 4 — Merge

After agents finish, follow the merge plan from the script output:

1. **Stash or commit local changes** — `git stash` if the working tree is dirty
2. **Remove worktrees** before rebasing — `git rebase` cannot operate on branches
   that are checked out in a worktree
3. **Review each branch** — inspect diffs and commit logs
4. **Merge** — use the rebase or merge-commit plan from the output
5. **Clean up** — run `cleanup.sh <slug-1> <slug-2> ...` to remove worktrees and branches

## Notes

- This skill creates worktrees and launches agents. It does NOT create issues, detect conflicts, or merge branches.
- The launch script is idempotent — it skips worktrees that already exist and panes that are already open.
- Worktree paths are siblings to the repo to avoid untracked directory noise.
- If `--prompts-dir` is omitted, agents launch with bare `claude` (no initial prompt).
- The merge plan shows both rebase (linear history) and merge (merge commit) options — the user picks whichever fits the project.
- To discard all worktrees and branches: `cleanup.sh <slug-1> <slug-2> ...`
- Prompt files are kept in `~/.claude/parallel/sessions/` for audit trails and re-runs.
- Set `PARALLEL_MAX_PANES` to override the default limit of 16 panes per tmux window.
