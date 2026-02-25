# /refactor-plan

Produce a structured refactoring plan for a file in this dotfiles repo.

## Instructions

When this skill is invoked, follow this workflow:

### Phase 1 — Audit

1. Read the target file end-to-end.
2. Produce a numbered structural audit listing:
   - Sections that are misplaced or could be grouped better
   - Dead code, redundant blocks, or `[SUGGESTION]`-marked items
   - Naming or ordering inconsistencies
3. Present the audit to the user and wait for feedback.

### Phase 2 — Propose

4. Propose a deep reorganization with a section outline (numbered sections, per-feature grouping).
5. Follow this repo's heading conventions:
   - 80-cpl `####` fences for top-level numbered sections (§1, §2, …)
   - 60-cpl `# ---` boxes for tool subsections (no number)
6. Wait for user approval before implementing.

### Phase 3 — Implement

7. Implement changes in committed phases — each major structural change gets its own commit.
8. Use Conventional Commits: `refactor(scope): description`.
9. After all changes, update CLAUDE.md if new conventions or section maps changed.

## Notes

- Default to deep structural reorganization, not cosmetic cleanup.
- If scope is unclear, ask upfront: "Full restructure or targeted cleanup?"
- Preserve all existing functionality — refactoring is structural, not behavioral.
