---
description: Create a clean, atomic git commit from the current changes. Use whenever the user says "commit", "commit this", or invokes /commit.
allowed-tools:
  - Bash(git init)
  - Bash(git add *)
  - Bash(git status)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git branch --show-current)
  - Bash(git commit *)
  - Bash(bash *pre-flight*)
  - Bash(bash *analyse-changes*)
  - Bash(bash *effort-level*)
  - Bash(bash *validate-message*)
  - Bash(cat *validate-message*)
---

# /commit

## Context

- User hint: $ARGUMENTS
- Pre-flight: !`bash ~/.claude/skills/commit/scripts/pre-flight.sh`
- Current branch: !`git branch --show-current 2>/dev/null || echo "N/A"`
- Change analysis: !`bash ~/.claude/skills/commit/scripts/analyse-changes.sh 2>/dev/null || echo "N/A"`
- Full diff: !`git diff HEAD 2>/dev/null || echo "N/A"`
- Recent commits: !`git log --oneline -10 2>/dev/null || echo "N/A"`
- Effort level: !`bash ~/.claude/skills/commit/scripts/effort-level.sh`

## Instructions

### Not a git repository

If the git check above shows "NOT_A_GIT_REPO":

1. Tell the user this directory is not a git repository.
2. Run `git init` to initialise one.
3. Stage all files by name (review the directory contents first — never use
   `git add -A` or `git add .`). Skip files that look like secrets or build
   artefacts (`.env`, `node_modules/`, `dist/`, etc.).
4. Create the initial commit with the message `chore: initial commit` plus the
   Co-Authored-By trailer (see `references/message-format.md`).
5. Run `git status` to confirm success, then stop.

### No changes detected

If the change analysis shows "No changes detected", tell the user and stop.

If the user hint is non-empty, use it to guide which files to stage and what the
commit message should convey. The hint may describe the scope ("the /parallel
changes"), the intent ("fix typo in README"), or both. It is a hint, not a
literal commit message — still apply Conventional Commits format and the
atomicity rules below.

### Step 1 — Stage and verify atomicity

Use the change analysis above (directory groups and atomicity signal) as the
starting point for your atomicity assessment.

1. Review the directory grouping and the full diff to determine whether changes
   form one or more logical units of work. If a user hint is present, use it to
   identify which subset of changes to stage.
2. **The "and" test**: draft a one-line summary. If it contains "and" connecting
   two independent actions (e.g., "improve X **and** enable Y"), it's two
   commits — split them. A shared topic or session does not make unrelated
   changes atomic.
3. **If everything is a single logical change**: stage all modified files by name
   (e.g., `git add file1 file2`) and proceed.
4. **If changes should be split into multiple commits**: explain the split,
   listing which files/hunks belong to each commit. Stage only the first logical
   unit (use `git add <file>` or `git add -p <file>` for partial staging) and
   proceed with that commit. **Stop after committing the first unit** — do not
   continue to the next. The user will invoke `/commit` again for the rest.
5. **Never use `git add -A` or `git add .`** — always stage files by name to
   avoid accidentally including untracked files.

### Step 2 — Compose commit message

Read `references/message-format.md` (in this skill's directory) for the full
Conventional Commits format, type table, and Co-Authored-By trailer spec.

Draft the commit message following that format. Use the recent commits above for
style consistency.

- **Scope**: derive from the directory grouping in the change analysis. If
  changed files share a common directory or component, use it as scope. Omit
  scope only when changes are genuinely cross-cutting or all files are in the
  repository root with no directory structure.
- **Effort level**: use the effort level from context above. Include it in the
  Co-Authored-By trailer unless it shows `N/A`.

### Step 3 — Validate and commit

1. Validate the draft message before committing:
   ```
   cat <<'EOF' | bash ~/.claude/skills/commit/scripts/validate-message.sh
   <full draft message here>
   EOF
   ```
2. If validation fails, fix the issues and re-validate.
3. Stage files and create the commit using a HEREDOC for correct formatting.
4. Run `git status` after committing to confirm success.

## Safety rules

- **Never amend** a previous commit unless the user explicitly asks for `--amend`.
- **Never skip hooks** (`--no-verify`) unless the user explicitly asks.
- **Never force-push** unless the user explicitly asks — and warn before doing so.
- **If a pre-commit hook fails**: fix the issue, re-stage, and create a NEW
  commit. Do not amend — the failed commit never happened, so amending would
  modify the wrong commit.

## Notes

- This skill is project-agnostic — it works in any repository.
- Projects can override this by creating `.claude/skills/commit/SKILL.md` at
  project level.
