# Tasks

One file per task: `NN-slug.md` (e.g. `01-auth-flow.md`). These files are the source
of truth for task state; the `task-tracker` agent reconciles them with repo evidence.

## Task file format

```markdown
---
title: Short imperative title
status: backlog | todo | doing | blocked | done
labels: [api, web, infra]
---

Context: one or two lines — why this exists, link to spec/plan if any.

## Subtasks

- [ ] concrete, verifiable step
- [ ] concrete, verifiable step
```

## Rules

- Status changes and checked boxes must be backed by evidence (diff, tests, docs).
- Specs from `docs/superpowers/specs/` graduate into tasks when implementation starts;
  plans from `docs/superpowers/plans/` map 1:1 to task subtasks.
- `done` tasks stay in place — they are project history, not clutter.
