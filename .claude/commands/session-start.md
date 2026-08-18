---
description: Load project state from memory before starting work
---

Before doing anything else, load the project's persistent context:

1. Read `memory/MEMORY.md` in full.
2. Read the most recent file(s) in `memory/episodic/`.
3. Read `docs/ROADMAP.md` (Now section).
4. Summarize in 3–5 lines: current state, open threads, constraints that apply.

Rules:
- Do NOT ask the user anything already answered in these files.
- If context seems missing, search `memory/episodic/` history before asking.
- If MEMORY.md contains `CONFLICT:` entries, surface them and ask the user to settle
  them before starting new work.

$ARGUMENTS
