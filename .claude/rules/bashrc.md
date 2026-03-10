---
paths:
  - "bash/bashrc"
---

- **Adding a new alias or function**: place it in the appropriate subsection of §8 (ALIASES) or §9 (FUNCTIONS). Do not append to the end of the file.
- **Adding a new tool** (with its own PATH, aliases, and completions): add a new subsection in the appropriate §10–§14 category, or create a new §15+ category. Keep PATH + aliases + completions for that tool together.
- **Heading hierarchy in §10–§14**: category sections use 80-cpl `####` fences (same style as §1–§9); tool subsections use 60-cpl `# ---` boxes with no number. Do not mix the two styles.
- **`[SUGGESTION]` comments**: these are annotate-only markers for dead/broken code — do not remove them without also fixing or deleting the code they describe. Do not add new `[SUGGESTION]` comments for things that are working correctly.
- **Do not scatter tool-specific PATH entries** into §2 (PATH SETTINGS); §2 is for general/bootstrap PATH only. Tool-specific PATH belongs in the tool's own subsection within §10–§14.
- **Self-aliases** (`alias foo=foo` after `function foo`) are no-ops in bash — do not add new ones.
- **`$1`/`$2` in aliases** are not expanded; use a function instead if arguments are needed.
- **Trust existing shell syntax** — if unsure whether constructs like `alias -- -='cd -'` are valid, assume they work.
