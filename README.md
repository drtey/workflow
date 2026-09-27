# workflow-skeleton

Skeleton for LLM-agent-driven development. Copy this directory to start a new project
with the harness (hooks, agents, commands), the directives, and a persistent memory
system already wired, for Claude Code.

## What's inside

```
CLAUDE.md                    directives (procedural memory) — fill the TODO(project) slots
                             CLAUDE.md auto-imports memory/MEMORY.md (@import)
.claude/
  settings.json              hook wiring + superpowers/ponytail plugins
  hooks/pre-bash.sh          blocks destructive commands (rm -rf, force push, DROP…)
  hooks/pre-read.sh          blocks full Read of files > 350 lines (READ_MAX_LINES)
                             — delegate to bulk-reader or read a range (saves tokens)
  hooks/post-edit.sh         secret scan (always on) + your stack's checks
  hooks/on-stop.sh           appends raw git facts to memory/episodic/<date>.md
                             (wired to Stop AND PreCompact — compaction can't lose context)
  agents/                    bulk-reader (haiku) · memory-curator · task-tracker · dead-code-remover · code-reviewer
  commands/                  /session-start · /memory-curate · /new-project
memory/
  MEMORY.md                  semantic memory (curated, timestamped, supersede-don't-delete)
  episodic/                  raw session records (append-only, hook-written)
docs/
  ROADMAP.md                 what's being worked on
  ARCHITECTURE.md            codebase map, kept in sync with structure changes
  tasks/                     task board in markdown (task-tracker reconciles)
  superpowers/{specs,plans}/ where brainstorming/writing-plans write
scripts/test-hooks.sh        fixture tests for the hooks (throwaway git sandbox)
```

## Bootstrap a new project

1. Copy this directory (or use it as a template repo), rename, `git init`.
2. In Claude Code run `/new-project` — it walks every `TODO(project)` marker
   (or `grep -rn "TODO(project)" . --exclude-dir=.git`).
3. Wire your stack's lint/test checks into `.claude/hooks/post-edit.sh` and
   `.claude/hooks/on-stop.sh` (marked sections).

Validate the hooks after any change: `bash scripts/test-hooks.sh`.

## The memory loop (write → manage → read)

Based on the write–manage–read model for agent memory:

- **Write** — automatic. The Stop hook appends raw git facts (branch, head, commits,
  working tree) to `memory/episodic/<date>.md`; it also runs on PreCompact, so context
  compaction never loses the raw record. Agents may append richer notes. Raw records
  only at this stage: summaries drift, raw records don't.
- **Manage** — `/memory-curate`. The `memory-curator` agent consolidates new episodic
  entries into `memory/MEMORY.md`: timestamped entries, supersede instead of delete,
  contradictions flagged `CONFLICT:` for the user to settle, stale facts marked.
- **Read** — `memory/MEMORY.md` is auto-imported into every Claude Code session via
  `@import` in CLAUDE.md; `/session-start` additionally loads the latest episodic log.
  Never re-ask what's already recorded.

Temporal scopes: working = context window · episodic = `memory/episodic/` ·
semantic = `memory/MEMORY.md` · procedural = `CLAUDE.md` (under git —
memory treated as code).

## Requirements

- [Claude Code](https://claude.com/claude-code) with the `superpowers` and
  `ponytail` plugins enabled (already set in `.claude/settings.json`).
