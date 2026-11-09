---
name: run-agent-tasks
description: Execute Notion tasks the owner approved for agents (Status Next, Agent OK ticked) using vault context, then hand results back for review. Use when the owner says run agent tasks, do the approved tasks, or get to work.
hooks:
  Stop:
    - hooks:
        - type: command
          command: python3 "$CLAUDE_PROJECT_DIR/_system/hooks/reflect-gate.py"
---

# /run-agent-tasks

## 0. Load context
`CLAUDE.md`, `_system/autonomy.md` (this governs everything below), `_system/notion-bridge.md`, `_me/Profile.md`.

## 1. Find work
Query the Tasks data source for (`Agent OK` ticked OR `Approved by = policy`) AND Status in (`Next`, `Doing`), **whatever the Executor**. `Agent`: do it all. `Together`: do every part an agent can, then hand the owner a clear guide for their part. `Me` with Agent OK: do what their feedback on the page asks (e.g. create tasks, write up steps); the rest stays theirs. Re-run the query just before close-out: the owner may move tasks to Next during a run. `Approved by = policy` only counts once `_system/escalation.md` says the auto-approval row is active (phase 5); before that, ignore it. List them to the owner (title, project, Duration) and start, smallest/clearest first, unless the owner picks. If the properties don't exist, stop and tell the owner.

## 2. For each task, one at a time
**Recurring tasks** (title starts with `Weekly:` or the page has a `## Recurrence` section): follow that section instead of steps 5–6 (it says when to skip, what to append, and which Status to leave).

1. Fetch the task page. Read its `Source` note, the linked project note (and `repo:`), and the relevant `_me` notes.
   - **The owner's answers can live in the vault, not only in Notion.** If an earlier result asked them questions in a note, open that note and check `git log -p` for their edits since the result (they may answer inline in Obsidian or in the day's brief). A heading `## Feedback` counts the same as `## Owner feedback`.
   - **Revision:** if the page has a `## Owner feedback` (or `## Feedback`) section newer than the latest `## Agent result`, this is a redo. Treat the feedback as the brief: revise the existing output (same note, same branch) rather than starting over, and address every point. Feedback can narrow or change the Definition of done but never widens the Amber limits.
2. No concrete Definition of done → set `Waiting`, `Waiting For = Owner: definition of done`, next task.
3. Set Status `Doing`.
4. Do the work within the Amber limits:
   - Research, plans, drafts → write a note in `05 Notes/` (or in the project note), with sources.
   - Code → work in the project's `repo:` on a new git branch, follow that repo's `CLAUDE.md`, and run its tests. Never push or deploy unless the task says so and it isn't a Red action. For big repo work, suggest the owner opens a session in that repo instead.
   - Anything Red → stop before it and record exactly what the owner needs to do.
5. Append to the task page:
   ```
   ## Agent result (YYYY-MM-DD)
   **Done:** <what was produced; vault paths / branch / links>
   **Definition of done check:** <each item: met / not met, why>
   **Needs you:** <review, decision, or Red action, or "just review">
   ```
   For a revision, title it `## Agent result (YYYY-MM-DD, revision)` and add `**Feedback addressed:** <each point: how>`. Never edit or delete the owner's feedback or earlier results.
6. Set `Waiting` with `Waiting For = Owner: review agent result` (or the specific blocker). For a project with a `repo:`, write the owner's hands-on steps and decisions into that repo's `YOUR-STEPS.md` (create it if missing, newest task first, remove sections for Done tasks) and name the file in `Waiting For`, so the owner knows where to look. Set `Done` only if the Definition of done explicitly says no review is needed.
7. Add a line to the related idea/project note's `## Log`.

## 3. Close out
- `_system/logs/agent-runs/YYYY-MM-DD.md`: tasks attempted, outcome, where the output is, time spent.
- Reflect: append 0–3 lessons to `_system/playbook.md` (or "no new lesson" in the run log). A Stop hook checks it.
- `git add -A && git commit -m "agent-run YYYY-MM-DD"` in the vault.
- Report to the owner: per task, one line of result and what they need to do.
