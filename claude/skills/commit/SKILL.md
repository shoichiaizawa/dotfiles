# /commit

Create a clean, atomic git commit from the currently staged changes.

## Instructions

When this skill is invoked, follow this workflow:

### Step 1 — Review staged changes

1. Run `git status` and `git diff --cached` to inspect what is staged.
2. If nothing is staged, tell the user and stop — never auto-stage with `git add -A` or `git add .`.
3. Run `git log --oneline -5` to see recent commit style for context.

### Step 2 — Verify atomicity

4. Check whether the staged changes represent a single logical unit of work.
5. If unrelated changes are bundled (e.g., a bug fix mixed with a refactor), warn the user and suggest splitting into separate commits. List which files/hunks belong to which commit.
6. Wait for user confirmation before proceeding if a split is recommended.

### Step 3 — Compose commit message

7. Draft a commit message using Conventional Commits format:
   ```
   <type>(<scope>): <summary>
   ```
   - **type**:

     | Type | Use when… |
     |------|-----------|
     | `feat` | Adding new functionality |
     | `fix` | Fixing a bug |
     | `refactor` | Changing code without changing behavior (includes dead code removal) |
     | `docs` | Documentation-only changes |
     | `style` | Formatting, whitespace, comments — no behavioral change |
     | `test` | Adding or correcting tests |
     | `build` | Build system or external dependency changes |
     | `ci` | CI/CD configuration changes |
     | `perf` | Performance improvements |

     Avoid `chore` — it exists in Conventional Commits but is a catch-all that obscures intent. Most changes that feel like `chore` are better described as `refactor` (dead code removal), `build` (dependency updates), `style` (comment cleanup), or `ci` (pipeline changes). Use `chore` only when nothing else fits.

   - **scope**: the module, component, or area of the codebase being changed (e.g., `auth`, `api`, `cli`, `config`). Optional — omit when the change is cross-cutting.
   - **summary**: imperative mood, lowercase, no period, under 72 characters
8. Add body text (separated by blank line) only if the "why" isn't obvious from the summary.
9. Always append the Co-Authored-By trailer:
   ```
   Co-Authored-By: Claude (<model> <version>, <effort>) <noreply@anthropic.com>
   ```
   - `<model>`: model family — Opus, Sonnet, or Haiku
   - `<version>`: model version — e.g., 4.6, 4.5
   - `<effort>`: reasoning effort — high, medium, or low
   - Use your actual model identity from your system context.
   - Example: `Co-Authored-By: Claude (Opus 4.6, high) <noreply@anthropic.com>`

### Step 4 — Commit

10. Create the commit. Use a HEREDOC to pass the message for correct formatting.
11. Run `git status` after committing to confirm success.

## Safety rules

- **Never amend** a previous commit unless the user explicitly asks for `--amend`.
- **Never skip hooks** (`--no-verify`) unless the user explicitly asks.
- **Never force-push** unless the user explicitly asks — and warn before doing so.
- **If a pre-commit hook fails**: fix the issue, re-stage, and create a NEW commit. Do not amend — the failed commit never happened, so amending would modify the wrong commit.
- **Do not stage unstaged changes** without explicit user approval. The user controls what goes into each commit.

## Notes

- This skill is project-agnostic — it works in any repository.
- Projects can override this by creating `.claude/skills/commit/SKILL.md` at project level.
