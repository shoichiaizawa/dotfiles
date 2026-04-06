# Commit Message Format

## Structure

```
<type>(<scope>): <summary>

[optional body]

Co-Authored-By: <agent> (<model>[, <effort>]) <email>
```

## Type reference

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

Avoid `chore` — it's a catch-all that obscures intent. Most changes that feel like
`chore` are better described as `refactor` (dead code removal), `build` (dependency
updates, config tuning), `style` (comment cleanup), or `ci` (pipeline changes).
Use `chore` only when nothing else fits.

## Scope

Derive from the common directory or component of the changed files (e.g., `auth`,
`api`, `cli`, `config`). Omit only when changes are genuinely cross-cutting or all
files are in the repository root with no directory structure.

## Summary

- Imperative mood ("add", not "added" or "adds")
- Lowercase first letter
- No trailing period
- Under 72 characters

## Body

Add body text (separated by blank line from the subject) only if the "why" isn't
obvious from the summary.

## Co-Authored-By trailer

Always append a trailer identifying the AI agent:

```
Co-Authored-By: <agent> (<model>[, <effort>]) <email>
```

- `<agent>`: the coding agent name (e.g., Claude, Codex, Cursor)
- `<model>`: friendly model name from system context (e.g., Opus 4.6, o3-pro, Sonnet 4.6)
- `<effort>`: reasoning effort level from the skill context. Include when available; omit only when the context shows `N/A`
- `<email>`: the agent's noreply address
- Use your actual identity from your system context.

**Examples:**
- `Co-Authored-By: Claude (Opus 4.6, high) <noreply@anthropic.com>`
- `Co-Authored-By: Codex (o3-pro) <noreply@openai.com>`
- `Co-Authored-By: Cursor (Sonnet 4.6) <noreply@cursor.com>`
