#!/usr/bin/env bash
# PreToolUse hook (Read) — blocks full reads of large files to save tokens.
# Receives tool call JSON on stdin (tool_input.file_path/offset/limit).
# Exit 2 blocks the Read and shows stderr to the agent, which then delegates
# to the bulk-reader agent (haiku) or re-reads a targeted range.
set -euo pipefail

INPUT=$(cat)
read -r TARGETED FILE < <(python3 -c "
import sys, json
t = json.load(sys.stdin).get('tool_input', {})
print(int('offset' in t or 'limit' in t), t.get('file_path', ''))
" <<< "$INPUT" 2>/dev/null || echo "") || true

[ -z "${FILE:-}" ] && exit 0
[ "${TARGETED:-0}" = "1" ] && exit 0
[ ! -f "$FILE" ] && exit 0

# ponytail: extension list, not MIME sniffing — Read renders these, not as text
shopt -s nocasematch
case "$FILE" in
    *.png|*.jpg|*.jpeg|*.gif|*.webp|*.pdf|*.ipynb) exit 0 ;;
esac

MAX=${READ_MAX_LINES:-350}
LINES=$(wc -l < "$FILE" | tr -d ' ')
if [ "$LINES" -gt "$MAX" ]; then
    echo "BLOCKED: $FILE has $LINES lines (> $MAX)." >&2
    echo "To understand it: delegate to the bulk-reader agent with a concrete question." >&2
    echo "To edit it: Read with offset/limit for the exact range you need." >&2
    exit 2
fi

exit 0
