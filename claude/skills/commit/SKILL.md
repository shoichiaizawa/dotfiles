---
description: Create a clean, atomic git commit from the current changes. Use whenever the user says "commit", "commit this", or invokes /commit.
allowed-tools:
  - Bash(git add *)
  - Bash(git status)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git branch --show-current)
  - Bash(git commit *)
---

# /commit

## Context

- Current branch: !`git branch --show-current`
- Current git status: !`git status`
- Staged and unstaged changes: !`git diff HEAD`
- Recent commits: !`git log --oneline -10`

## Instructions

If there are no changes at all (nothing staged, nothing unstaged, no untracked files), tell the user and stop.

### Step 1 — Stage and verify atomicity

1. Review all changes (staged + unstaged) and determine whether they form one or more logical units of work.
2. **If everything is a single logical change**: stage all modified files by name (e.g., `git add file1 file2`) and proceed.
3. **If changes should be split into multiple commits**: explain the split, listing which files/hunks belong to each commit. Stage only the first logical unit (use `git add <file>` or `git add -p <file>` for partial staging) and proceed with that commit. **Stop after committing the first unit** — do not continue to the next. The user will invoke `/commit` again for the rest.
4. **Never use `git add -A` or `git add .`** — always stage files by name to avoid accidentally including untracked files.

### Step 2 — Compose commit message

5. Draft a commit message using Conventional Commits format:
   ```
   <type>(<scope>): <summary>
   ```
   - **type**:

     | Type | Use when… |
     |------|-----------|
     | `feat` | Adding new functionality |
     | `fix` | Fixing a bug |
     | `refactor` | Changing code without changing behaviour (includes dead code removal) |
     | `docs` | Documentation-only changes |
     | `style` | Formatting, whitespace, comments — no behavioural change |
     | `test` | Adding or correcting tests |
     | `build` | Build system, external dependency, or config value changes (e.g., pool sizes, timeouts, resource limits) |
     | `ci` | CI/CD configuration changes |
     | `perf` | Performance improvements |

     Avoid `chore` — it exists in Conventional Commits but is a catch-all that obscures intent. Most changes that feel like `chore` are better described as `refactor` (dead code removal), `build` (dependency updates, config tuning), `style` (comment cleanup), or `ci` (pipeline changes). Use `chore` only when nothing else fits.

   - **scope**: the module, component, or area of the codebase being changed (e.g., `auth`, `api`, `cli`, `config`). Optional — omit when the change is cross-cutting.
   - **summary**: imperative mood, lowercase, no period, under 72 characters
6. Add body text (separated by blank line) only if the "why" isn't obvious from the summary.
7. Always append a Co-Authored-By trailer identifying the AI agent:
   ```
   Co-Authored-By: <agent> (<model>[, <effort>]) <email>
   ```
   - `<agent>`: the coding agent name (e.g., Claude, Codex, Cursor)
   - `<model>`: friendly model name from your system context (e.g., Opus 4.6, o3-pro, Sonnet 4.6)
   - `<effort>`: reasoning effort level, if the agent supports it — omit if not applicable
   - `<email>`: the agent's noreply address
   - Use your actual identity from your system context.
   - Examples:
     - `Co-Authored-By: Claude (Opus 4.6, high) <noreply@anthropic.com>`
     - `Co-Authored-By: Codex (o3-pro) <noreply@openai.com>`
     - `Co-Authored-By: Cursor (Sonnet 4.6) <noreply@cursor.com>`

### Step 3 — Commit

8. Stage files and create the commit in a single message. Use a HEREDOC to pass the commit message for correct formatting.
9. Run `git status` after committing to confirm success.

## Safety rules

- **Never amend** a previous commit unless the user explicitly asks for `--amend`.
- **Never skip hooks** (`--no-verify`) unless the user explicitly asks.
- **Never force-push** unless the user explicitly asks — and warn before doing so.
- **If a pre-commit hook fails**: fix the issue, re-stage, and create a NEW commit. Do not amend — the failed commit never happened, so amending would modify the wrong commit.

## Notes

- This skill is project-agnostic — it works in any repository.
- Projects can override this by creating `.claude/skills/commit/SKILL.md` at project level.
