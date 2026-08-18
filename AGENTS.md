# AGENTS.md

> Mirrors CLAUDE.md — keep both files in sync. CLAUDE.md is canonical.

TODO(project): one-liner — what this project is.

Ground truth: [docs/ROADMAP.md](docs/ROADMAP.md) (current state) ·
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) (codebase map) ·
[memory/MEMORY.md](memory/MEMORY.md) (durable context).

## Memory protocol (read first)

1. **Session start**: read `memory/MEMORY.md` and the latest `memory/episodic/` log.
   (Claude Code auto-imports MEMORY.md via `@import` in CLAUDE.md — do not duplicate
   the import here.) Do not ask the user anything already answered there; if context
   is missing, search `memory/episodic/` history before asking.
2. **During work**: durable facts (decisions, constraints, preferences, gotchas)
   belong in memory — the Stop hook captures raw git facts automatically, and agents
   may append richer notes to the day's episodic file. Do NOT rewrite or delete
   episodic entries — append only.
3. **Curation**: consolidate episodic logs into MEMORY.md with the `memory-curator`
   agent. Entries are timestamped and superseded, never silently deleted; `CONFLICT:`
   entries must be surfaced and settled with the user.

## Stack

TODO(project): language, framework, database, hosting, key libraries.

## Commands

TODO(project): dev / build / test / lint commands.

## Architecture

TODO(project): summarize the layering and the dependency rule; full map in
docs/ARCHITECTURE.md. If a task would break the dependency rule, STOP and propose
alternatives instead.

## TDD, no exceptions

- Do NOT write implementation code without a failing test first — red, green, refactor.
- Do NOT fix a bug without a failing repro test first — write the repro, then the fix.
- Do NOT declare work DONE until tests pass AND lint passes.

## Coding approach

- Do NOT assume — state assumptions explicitly; if several interpretations exist,
  ask before coding.
- Do NOT write speculative code — no features nobody asked for, no abstraction with
  one implementation, no config for a value that never changes.
- Do NOT touch code the task doesn't require — no drive-by refactors, no "improving"
  adjacent formatting or comments.
- Do NOT delete dead code on the fly — mention it; the `dead-code-remover` agent
  handles it safely.
- Do NOT add dependencies for what the stdlib or an already-installed library does.

## Non-negotiable rules

1. Do NOT put secrets in code, logs, or commits — never.
2. Do NOT commit without tests passing; do NOT commit a broken build.
3. Do NOT `git push --force`, do NOT `git reset --hard`, do NOT `git clean -f`
   (hooks block these) — ask the user to run them manually if truly intended.
4. Do NOT push or deploy without an explicit user request — even when everything is green.
5. Do NOT edit or delete past `memory/episodic/` entries — append only.
6. Do NOT silently resolve contradictions in memory — flag them `CONFLICT:` and ask.
7. TODO(project): domain rules.

## Conventions

- Trunk-based: commit direct to `main`, conventional commits (`feat:`, `fix:`, …).
- Do NOT let docs lag — spec/plan/doc updates ship with the change they describe.
- Do NOT alter the codebase structure without updating docs/ARCHITECTURE.md's module
  map in the same change.

## Agents

Canonical definitions live in `.claude/agents/*.md` (opencode ports in
`.opencode/agent/` delegate to them):

- `memory-curator` — consolidate episodic → semantic memory.
- `task-tracker` — reconcile `docs/tasks/*.md` with repo evidence.
- `dead-code-remover` — verified dead-code deletion in tested batches.
- `code-reviewer` — read-only diff review, verdict first.
