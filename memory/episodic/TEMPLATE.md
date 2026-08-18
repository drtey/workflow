# Episodic log format

One file per day: `YYYY-MM-DD.md`, created and appended automatically by the Stop
hook (`.claude/hooks/on-stop.sh`) with raw git facts. **Append-only: never edit,
rewrite, or delete entries.** Summaries drift; raw records don't. Curation into
`../MEMORY.md` happens via `/memory-curate`.

Each entry looks like:

```markdown
## 14:32 — session stop

- branch: main
- head: ab12cd34
- commits since last stop:
  - ab12cd34 feat: add invoice export
- working tree:
  - M src/export.py
- diffstat (uncommitted):
    src/export.py | 12 +++++++-----
```

Agents may also append richer entries here (what was attempted, what failed, why a
decision was taken) — still raw, still dated, still append-only.
