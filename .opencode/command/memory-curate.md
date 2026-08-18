---
description: Manage phase of the memory loop — consolidate episodic logs into memory/MEMORY.md
---

Run the manage phase of the memory loop:

1. Dispatch the `memory-curator` subagent to consolidate `memory/episodic/`
   entries newer than the latest `memory/MEMORY.md` entry.
2. When it returns, show its report (added / updated / superseded / conflicts / stale).
3. If it flagged `CONFLICT:` entries, ask the user to settle each one now, then apply
   the resolution to `memory/MEMORY.md`.

$ARGUMENTS
