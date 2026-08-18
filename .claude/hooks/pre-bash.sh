#!/usr/bin/env bash
# PreToolUse hook (Bash) — blocks destructive shell commands.
# Receives tool call JSON on stdin (tool_input.command).
# Exits non-zero to block the Bash tool from running.
set -euo pipefail

INPUT=$(cat)
CMD=$(python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" <<< "$INPUT" 2>/dev/null || true)

[ -z "$CMD" ] && exit 0

BLOCKED=0
REASON=""

if echo "$CMD" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*\s+-[a-zA-Z]*f|rm\s+-[a-zA-Z]*f[a-zA-Z]*\s+-[a-zA-Z]*r|rm\s+-rf|rm\s+-fr'; then
    BLOCKED=1; REASON="rm -rf (irreversible deletion)"
fi

if echo "$CMD" | grep -qE 'git\s+reset\s+--hard'; then
    BLOCKED=1; REASON="git reset --hard (discards uncommitted work)"
fi

if echo "$CMD" | grep -qE 'git\s+push\s+.*(-f|--force)'; then
    BLOCKED=1; REASON="git push --force (can overwrite remote history)"
fi

if echo "$CMD" | grep -qE 'git\s+clean\s+.*-[a-zA-Z]*f'; then
    BLOCKED=1; REASON="git clean -f (irreversible deletion of untracked files)"
fi

if echo "$CMD" | grep -qiE '(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE)'; then
    BLOCKED=1; REASON="destructive SQL (DROP/TRUNCATE)"
fi

if [ "$BLOCKED" -eq 1 ]; then
    echo "BLOCKED: $REASON" >&2
    echo "Command: $CMD" >&2
    echo "Ask the user to run this manually if it is intentional." >&2
    exit 1
fi

exit 0
