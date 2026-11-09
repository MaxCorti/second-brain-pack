# Conventions

## File names
- Daily: `01 Daily/YYYY-MM-DD.md`. Weekly review: `01 Daily/Reviews/YYYY-Www.md`.
- Everything else: a human title in Title Case, no dates unless meaningful (`02 Ideas/Plant Watering App.md`).
- Search before creating. Extend an existing note rather than making a near-duplicate.

## Frontmatter by type
Every agent-written note has `type:` and `created:`. Dates are ISO (`YYYY-MM-DD`).

| type | Required fields |
|---|---|
| `daily` | `date`, `triaged` (false / true) |
| `capture` | `captured`, `source` (phone / laptop / other), `triaged` |
| `idea` | `status`, `area`, `created`, `sources` (list of `[[links]]`), `notion` (task/project URL or empty) |
| `project` | `status` (Notion snapshot), `synced` (date), `area`, `notion` (URL), `repo` (path or empty) |
| `area` | `notion_area` (exact Notion option) |
| `person` | `relationship`, `created` |
| `note` | `created`, `sources`, optional `project` |
| `profile` | `updated` |
| `review` | `week`, `created` |
| `brief` | `created` (in `_system/logs/briefs/`) |

### Idea status lifecycle
`seed` (just captured) → `exploring` (the owner returned to it or it got a next step) → `ready` (clear enough to act on) → `promoted` (became a Notion task/project; set `notion:`) / `parked` (not now) / `dropped` (move to `07 Archive/`). Only the owner decides `dropped`.

## Links and tags
- Link generously: people `[[Name]]`, projects, areas, ideas, the daily note a fact came from.
- `area:` uses a link to the area note, e.g. `area: "[[Build]]"`.
- Tags are optional and sparse; prefer links.

## Provenance syntax (used in `_me/`, ideas, people)
```
- Prefers mornings for deep work. (stated, [[01 Daily/YYYY-MM-DD]])
- Seems most focused after a walk. (inferred, [[01 Daily/YYYY-MM-DD]], [[01 Daily/YYYY-MM-DD]]); confirm
```
When a newer stated fact contradicts an older one, keep both with dates and mark the old one `(superseded YYYY-MM-DD)`.

## Agent-appended sections
Agents may append to agent-owned notes under a `## Log` heading, newest last: `- YYYY-MM-DD: <what changed> ([[source]])`.
