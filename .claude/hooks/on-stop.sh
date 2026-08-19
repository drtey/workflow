#!/usr/bin/env bash
# Stop hook — captures raw session facts into episodic memory.
# Raw git facts only, no summarization: curation is /memory-curate's job.
# Summaries drift; raw records don't. Informational only (agent already stopped).
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$ROOT"

MEM="memory/episodic"
mkdir -p "$MEM"

STAMP="$MEM/.last-rev"
LAST=$(cat "$STAMP" 2>/dev/null || echo "")
HEAD=$(git rev-parse --verify --quiet HEAD 2>/dev/null || echo "")
STATUS=$(git status --short 2>/dev/null || true)

# Stop fires at the end of every turn — skip when nothing meaningful changed
# since the last capture, or the log fills with identical stops. The signature
# excludes memory/ (the hook's own writes there dirty the tree otherwise).
SIGSTAMP="$MEM/.last-sig"
SIG="$HEAD|$(printf '%s\n' "$STATUS" | grep -v 'memory/' || true)"
if [ "$SIG" = "$(cat "$SIGSTAMP" 2>/dev/null || echo "")" ]; then
    exit 0
fi

FILE="$MEM/$(date +%Y-%m-%d).md"
if [ ! -f "$FILE" ]; then
    echo "# $(date +%Y-%m-%d) — episodic log (raw, append-only)" > "$FILE"
fi

{
    echo ""
    echo "## $(date '+%H:%M') — session stop"
    echo ""
    echo "- branch: $(git branch --show-current 2>/dev/null || echo detached)"
    [ -n "$HEAD" ] && echo "- head: ${HEAD:0:8}"
    if [ -n "$LAST" ] && [ -n "$HEAD" ] && [ "$LAST" != "$HEAD" ]; then
        echo "- commits since last stop:"
        git log --oneline "$LAST..$HEAD" 2>/dev/null | sed 's/^/  - /' || true
    fi
    if [ -n "$STATUS" ]; then
        echo "- working tree:"
        echo "$STATUS" | sed 's/^/  - /'
        DIFFSTAT=$(git diff HEAD --stat 2>/dev/null || true)
        if [ -n "$DIFFSTAT" ]; then
            echo "- diffstat (uncommitted):"
            echo "$DIFFSTAT" | sed 's/^/    /'
        fi
    else
        echo "- working tree: clean"
    fi
} >> "$FILE"

[ -n "$HEAD" ] && echo "$HEAD" > "$STAMP"
echo "$SIG" > "$SIGSTAMP"

# ── Project checks (optional) ─────────────────────────────────────────────────
# TODO(project): run your fast verification suite here, e.g.:
# make test-unit --no-print-directory -s || echo "test-unit FAILED — review before continuing" >&2

exit 0
