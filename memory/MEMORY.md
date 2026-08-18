# MEMORY.md — semantic memory (curated)

Durable knowledge distilled from session logs. **Read this at the start of every session.**

- Entry format: `- [YYYY-MM-DD] fact — why/context`.
- Never delete entries; supersede them: `- [YYYY-MM-DD] SUPERSEDED by [YYYY-MM-DD]: ...`
- Contradictions get flagged `CONFLICT:` and settled by the user, not silently resolved.
- Raw session history lives in `memory/episodic/` (append-only, never edited).
- Curate with `/memory-curate` (memory-curator agent).

<!-- ponytail: single file; split into memory/topics/<area>.md and link from here if it exceeds ~150 lines -->

## Decisions

- [2026-08-18] Skeleton created from project-f's harness setup — Claude Code canonical (`.claude/`), opencode bridge (`.opencode/`), markdown memory in git, Stop-hook episodic capture + `/memory-curate` curation.
- [2026-08-18] Context-loss hardening — MEMORY.md auto-imported via `@import` in CLAUDE.md (read phase needs no manual step); on-stop.sh also wired to PreCompact (Claude) and session.compacted/compacting (opencode); post-edit.sh scans written files for obvious secrets (.env excluded); hooks covered by scripts/test-hooks.sh. Dropped as YAGNI: curation nag (needs extra state) and SessionStart hook (redundant with @import + /session-start).

## Constraints

## Preferences

## Lessons

## Open questions
