#!/usr/bin/env bash
# Hook tests: each hook runs against fixture JSON inside a throwaway git sandbox.
# Usage: bash scripts/test-hooks.sh
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT
cp -R "$REPO_ROOT/.claude" "$SANDBOX/"
cd "$SANDBOX"
git init -q
git config user.email "hooks@test.local"
git config user.name "hooks-test"
echo "# sandbox" > README.md
git add -A && git commit -qm "init"

PASS=0
FAIL=0

expect() { # <desc> <want> <got>
    if [ "$2" = "$3" ]; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        echo "FAIL: $1 (want $2, got $3)" >&2
    fi
}

pre() { # <command> -> exit code of pre-bash.sh
    local code=0
    printf '{"tool_input":{"command":"%s"}}' "$1" | bash .claude/hooks/pre-bash.sh >/dev/null 2>&1 || code=$?
    echo "$code"
}

post() { # <file> -> exit code of post-edit.sh
    local code=0
    printf '{"tool_input":{"file_path":"%s"}}' "$1" | bash .claude/hooks/post-edit.sh >/dev/null 2>&1 || code=$?
    echo "$code"
}

# ── pre-bash: blocked ─────────────────────────────────────────────────────────
expect "blocks rm -rf"       1 "$(pre 'rm -rf /tmp/x')"
expect "blocks rm -fr"       1 "$(pre 'rm -fr /tmp/x')"
expect "blocks reset --hard" 1 "$(pre 'git reset --hard HEAD~1')"
expect "blocks push --force" 1 "$(pre 'git push --force origin main')"
expect "blocks push -f"      1 "$(pre 'git push -f origin main')"
expect "blocks git clean -f" 1 "$(pre 'git clean -fd')"
expect "blocks DROP TABLE"   1 "$(pre "psql -c 'DROP TABLE users;'")"

# ── pre-bash: allowed ─────────────────────────────────────────────────────────
expect "allows ls"         0 "$(pre 'ls -la')"
expect "allows git status" 0 "$(pre 'git status')"
expect "allows plain push" 0 "$(pre 'git push origin main')"
expect "allows plain rm"   0 "$(pre 'rm notes.txt')"

# ── pre-bash: fail-open on bad input ──────────────────────────────────────────
code=0; echo '' | bash .claude/hooks/pre-bash.sh >/dev/null 2>&1 || code=$?
expect "empty stdin fails open" 0 "$code"
code=0; echo 'not json' | bash .claude/hooks/pre-bash.sh >/dev/null 2>&1 || code=$?
expect "bad json fails open" 0 "$code"

# ── post-edit ─────────────────────────────────────────────────────────────────
expect "ignores missing file" 0 "$(post "$SANDBOX/nope.py")"

mkdir -p src
echo 'def add(a, b): return a + b' > src/clean.py
expect "allows clean file" 0 "$(post "$SANDBOX/src/clean.py")"

# fixture secrets are built by concatenation so this test file never contains
# a literal pattern (it would trip the scan when edited itself)
AWS_KEY="AKIA""IOSFODNN7EXAMPLE"
GH_TOKEN="ghp_""abcdefghijklmnopqrstuvwxyz0123456789"
PKEY_HDR="-----BEGIN ""OPENSSH PRIVATE KEY-----"

printf 'key = "%s"\n' "$AWS_KEY" > src/leak_aws.py
expect "blocks AWS key" 1 "$(post "$SANDBOX/src/leak_aws.py")"

printf 'token = "%s"\n' "$GH_TOKEN" > src/leak_gh.py
expect "blocks GitHub token" 1 "$(post "$SANDBOX/src/leak_gh.py")"

printf '%s\nfake\n' "$PKEY_HDR" > src/leak_key.pem
expect "blocks private key" 1 "$(post "$SANDBOX/src/leak_key.pem")"

printf 'AWS_KEY=%s\n' "$AWS_KEY" > .env
expect "skips .env (secrets live there)" 0 "$(post "$SANDBOX/.env")"

expect "no self-trigger on hook script" 0 "$(post "$SANDBOX/.claude/hooks/post-edit.sh")"

# ── on-stop ───────────────────────────────────────────────────────────────────
code=0; bash .claude/hooks/on-stop.sh >/dev/null 2>&1 || code=$?
expect "on-stop exits 0" 0 "$code"

LOG="memory/episodic/$(date +%Y-%m-%d).md"
found=1
if [ -f "$LOG" ] && grep -q "session stop" "$LOG"; then found=0; fi
expect "writes episodic entry" 0 "$found"

code=0; bash .claude/hooks/on-stop.sh >/dev/null 2>&1 || code=$?
count=$(grep -c "session stop" "$LOG")
if [ "$count" -ge 2 ]; then appended=0; else appended=1; fi
expect "appends on second run" 0 "$appended"

# ── on-stop: repo without commits ─────────────────────────────────────────────
EMPTY=$(mktemp -d)
cp -R "$REPO_ROOT/.claude" "$EMPTY/"
git -C "$EMPTY" init -q
code=0; (cd "$EMPTY" && bash .claude/hooks/on-stop.sh) >/dev/null 2>&1 || code=$?
expect "on-stop ok without commits" 0 "$code"
bogus=0
if grep -q "head: HEAD" "$EMPTY/memory/episodic/$(date +%Y-%m-%d).md" 2>/dev/null; then bogus=1; fi
expect "no bogus head on empty repo" 0 "$bogus"
rm -rf "$EMPTY"

echo "hooks: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
