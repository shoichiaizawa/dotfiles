#!/usr/bin/env bash
# Validate a commit message against Conventional Commits format.
#
# Usage: validate-message.sh "single-line message"
#    or: echo "multi-line message" | validate-message.sh
#
# Exits 0 on success, 1 on failure.

set -euo pipefail

if [[ $# -ge 1 ]]; then
    msg="$1"
else
    msg=$(cat)
fi

subject=$(echo "$msg" | head -n1)
errors=()
warnings=()

# Conventional Commits format
if ! echo "$subject" | grep -qE '^(feat|fix|refactor|docs|style|test|build|ci|perf|chore)(\([a-z0-9._-]+\))?: .+'; then
    errors+=("Subject does not match format: type(scope): summary")
fi

# Length check
if [[ ${#subject} -gt 72 ]]; then
    errors+=("Subject is ${#subject} chars (max 72)")
fi

# No trailing period
if echo "$subject" | grep -qE '\.$'; then
    errors+=("Subject should not end with a period")
fi

# Lowercase summary (after type prefix)
summary=$(echo "$subject" | sed -E 's/^[a-z]+(\([a-z0-9._-]+\))?: //')
if echo "$summary" | grep -qE '^[A-Z]'; then
    errors+=("Summary should start with lowercase")
fi

# Co-Authored-By trailer — validate structure: Agent (Model[, effort]) <email>
trailer=$(echo "$msg" | grep -E '^Co-Authored-By: ' || true)
if [[ -z "$trailer" ]]; then
    errors+=("Missing Co-Authored-By trailer")
elif ! echo "$trailer" | grep -qE '^Co-Authored-By: [A-Za-z]+ \(.+\) <.+@.+>$'; then
    errors+=("Co-Authored-By trailer does not match format: Agent (Model[, effort]) <email>")
fi

# Warn on chore
if echo "$subject" | grep -qE '^chore(\(|:)'; then
    warnings+=("Consider a more specific type than chore (refactor, build, style, ci)")
fi

# Output
if [[ ${#errors[@]} -eq 0 ]]; then
    echo "PASS"
else
    echo "FAIL"
    for err in "${errors[@]}"; do
        echo "  - $err"
    done
fi

if [[ ${#warnings[@]} -gt 0 ]]; then
    for warn in "${warnings[@]}"; do
        echo "  WARN: $warn"
    done
fi

[[ ${#errors[@]} -eq 0 ]]
