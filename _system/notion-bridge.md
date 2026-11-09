# Notion bridge

Notion is the owner's command centre (called **Command** below; rename it if you like): the authoritative task and project record.

## IDs
Filled in once by the setup prompt (`NOTION-SETUP-PROMPT.md`). Until then, agents stop before any Notion write and tell the owner to run it.
- Command page: `<COMMAND_PAGE_ID>`
- Tasks data source: `<TASKS_DATA_SOURCE>`
- Projects data source: `<PROJECTS_DATA_SOURCE>`

Fetch the data source schema before writing. Property names below are exact.

## Command rules (the owner's, don't break them)
- At most 3 Active projects; at most 3 Daily Wins. Agents never set Daily Win.
- Scheduled ≠ Due. No fake deadlines: only set Due if the owner stated a real date.
- P1 - Critical only for real consequences, and only the owner sets it. Default P3 - Normal; P2 - Important if the owner said it matters.
- Agents never change a Project's Status.

## Creating a task (from /triage)
| Property | How to fill |
|---|---|
| Task | Verb-first, concrete: "Draft the About page copy for the portfolio site" |
| Status | Always `Inbox` |
| Executor | `Me` (the owner must do it), `Agent` (an agent can do it alone), `Together` (agent preps, the owner finishes) |
| Agent OK | Leave unticked. Only the owner ticks it |
| Source | Vault path of the note it came from, e.g. `01 Daily/YYYY-MM-DD.md` |
| Project | Relate to the matching Notion project if obvious; otherwise leave empty |
| Priority | Usually `P3 - Normal`; `P2 - Important` only if the owner signalled importance |
| Context / Mode / Energy / Duration | Fill when reasonably clear; leave empty rather than guess wildly |
| Due | Only a real stated deadline |

Page body template:
```
**Why:** <one line: the intention behind it, in the owner's words if possible>
**Source:** <vault path> (captured <date>)
**Definition of done:**
- <observable outcome 1>
- <observable outcome 2>
**Context for the executor:** <links to vault notes, repo path, constraints>
**Needs you for:** <Red actions, decisions or info only the owner has; or "nothing">
```
Executor = Agent tasks **must** have a concrete Definition of done. If you can't write one, the item isn't ready: make it an idea or an Executor = Me task "Decide what <x> should produce".

### Dedup before creating
Search Tasks for non-Done tasks with similar titles, and check the source note and idea note for an existing `notion:` link. Update or comment on the existing task instead of duplicating.

### Volume
Typically 0–8 tasks per triage. Bundle tiny related steps into one task. Task spam destroys trust in the system.

## Executing (from /run-agent-tasks)
Pick up tasks where `Status = Next` and either `Agent OK` is ticked or `Approved by = policy` (phase 5, see below), whatever the Executor (Agent: all of it; Together: the agent's part + a guide for the owner's; Me: what the owner's feedback asks). Also resume `Status = Doing`.

### Auto-approval (phase 5)
Active only when the "Auto-approving agent tasks" row of `_system/escalation.md` says "active since". Then `/brain` may move an `Executor = Agent` task from `Inbox` to `Next` **only** if it fits a pre-approved class in that row: it sets `Approved by = policy`, never ticks Agent OK, and writes `**Auto-approved (YYYY-MM-DD):** <class>, because <one line>` at the top of the page. Results still end in Waiting for the owner's review. The owner moving a task to `Someday` stops it. A class that misfires twice goes back to needing their tick (note it in the brief). When in doubt, it's not pre-approved.
Flow: set `Doing` → work → append `## Agent result (YYYY-MM-DD)` to the task page → set `Waiting` with `Waiting For = Owner: review agent result`. Only set `Done` if the Definition of done says "no review needed".
Blocked: set `Waiting` with `Waiting For = Owner: <what exactly>`.

### The owner's review
On a task waiting for `Owner: review agent result`, the owner does one of:
- **Accept:** sets `Done` (and does any Red action listed under "Needs you", or asks an agent to in the moment).
- **Request changes:** adds a `## Owner feedback (YYYY-MM-DD)` section to the page and sets Status back to `Next` (Agent OK stays ticked). The next /run-agent-tasks revises the existing output against that feedback.
- **Drop:** sets `Done` or deletes the task.

## Projects
`03 Projects/*.md` mirror Notion projects for context (`notion:` URL, `status` snapshot, `synced` date). Refresh snapshots during /weekly-review. A new project idea becomes a vault idea with `status: ready` and an owner task "Decide whether to start project X". Agents don't create Notion projects.

## Required Task properties
Executor (select: Me / Agent / Together), Agent OK (checkbox), Source (text). For phase 5: Approved by (select: Me / policy); without it, don't auto-approve. If they're missing, tell the owner rather than inventing a workaround.
