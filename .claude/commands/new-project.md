---
description: Bootstrap this skeleton into a concrete project — fill every TODO(project) marker
---

Walk the user through bootstrapping this skeleton:

1. `grep -rn "TODO(project)" . --exclude-dir=.git` to list every placeholder.
2. Go file by file, in this order, asking the user for each answer:
   - `CLAUDE.md` + `AGENTS.md`: project one-liner, stack, commands, architecture,
     domain-specific non-negotiable rules. Keep both files in sync.
   - `.claude/hooks/post-edit.sh` + `.claude/hooks/on-stop.sh`: wire the stack's
     lint/test checks into the marked sections.
   - `docs/ARCHITECTURE.md`: module map and dependency rule.
   - `docs/ROADMAP.md`: current focus.
3. Record durable answers (stack choices, constraints, rules) as entries in
   `memory/MEMORY.md` under Decisions/Constraints.
4. Re-run the grep — it must return nothing when done.

$ARGUMENTS
