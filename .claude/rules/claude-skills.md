---
paths:
  - "claude/skills/**/*"
---

- **Directory structure**: each skill lives in `claude/skills/<name>/SKILL.md`. The directory name becomes the slash-command (e.g., `claude/skills/commit/` → `/commit`).
- **No YAML frontmatter**: skills in this repo use a plain `# /<name>` heading, not YAML metadata blocks.
- **Global vs project-level**: skills in `claude/skills/` (symlinked to `~/.claude/skills/`) are available in all projects. A project can override a global skill by creating `.claude/skills/<name>/SKILL.md` at the project root.
- **Keep skills project-agnostic**: global skills should not reference repo-specific paths, tools, or conventions. Repo-specific instructions belong in CLAUDE.md or in a project-level skill override.
