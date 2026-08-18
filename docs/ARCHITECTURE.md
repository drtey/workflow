# Architecture

> Codebase map. Keep it in sync **in the same change** that alters structure.

TODO(project): one paragraph — what this is, stack, where it runs.

## Module map

TODO(project): tree of the main modules with a one-line purpose each, e.g.:

```
src/
  domain/    — business rules, no framework imports
  app/       — use cases / orchestration
  infra/     — adapters (DB, external APIs)
```

## Dependency rule

TODO(project): which layers may import which (e.g. "dependencies point inward only:
infra → app → domain; domain imports nothing"). Delete this section if not applicable.

## External services

| Service | What for | Where configured |
| ------- | -------- | ---------------- |
| TODO(project) |  |  |
