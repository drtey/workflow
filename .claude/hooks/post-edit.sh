#!/usr/bin/env bash
# PostToolUse hook (Edit/Write) — per-file quality gate, runs after every edit.
# Receives tool call JSON on stdin (tool_input.file_path).
# Exits non-zero to block and surface stderr to the agent. Keep every check fast (< ~5 s).
set -euo pipefail

INPUT=$(cat)
FILE=$(python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', ''))
" <<< "$INPUT" 2>/dev/null || true)

[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

PROJECT_ROOT=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$PROJECT_ROOT"

# ── Secret scan (always on, stdlib grep) ──────────────────────────────────────
# .env files are skipped — that's where secrets legitimately live (gitignored).
BASE=$(basename "$FILE")
if [[ "$BASE" != .env* && "$BASE" != *.env ]]; then
    if grep -qE '(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY)' "$FILE" 2>/dev/null; then
        echo "possible secret in $FILE — remove it (never write secrets to code or docs)" >&2
        exit 1
    fi
fi

# ── Project checks ────────────────────────────────────────────────────────────
# TODO(project): wire your stack's per-file quality gates here. Pattern:
#
# if [[ "$FILE" == *.py ]]; then
#     if ! uv run ruff check --quiet "$FILE"; then
#         echo "ruff: fix lint errors in $FILE before continuing" >&2
#         exit 1
#     fi
# fi
#
# if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
#     if ! npx --no-install eslint "$FILE"; then
#         echo "eslint: fix lint errors in $FILE before continuing" >&2
#         exit 1
#     fi
# fi
#
# if [[ "$FILE" == */src/* ]]; then
#     if ! make test-unit --no-print-directory -s; then
#         echo "unit tests failed — fix before proceeding" >&2
#         exit 1
#     fi
# fi

exit 0
