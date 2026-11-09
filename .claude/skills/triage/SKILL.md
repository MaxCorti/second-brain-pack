---
name: triage
description: Daily processing of the owner's captures. Reads 00 Inbox and untriaged daily notes, files ideas/people/projects/facts into the vault, updates _me with sourced facts, and proposes Notion tasks (Status Inbox). Use when the owner says triage, process my notes, or does their daily handover.
hooks:
  Stop:
    - hooks:
        - type: command
          command: python3 "$CLAUDE_PROJECT_DIR/_system/hooks/reflect-gate.py"
---

# /triage

Goal: nothing the owner captured gets lost, and only real intentions become Notion tasks.

## 0. Load context
Read `CLAUDE.md` (if not already), `_me/Profile.md`, `_system/notion-bridge.md`, `_system/autonomy.md`, `_system/conventions.md`. Fetch the Notion Tasks schema. If `Executor`, `Agent OK` or `Source` is missing, continue the vault part, put the would-be task fields in the log, and tell the owner at the end.

## 1. Collect input
- Every note in `00 Inbox/`.
- Every `01 Daily/*.md` with `triaged: false`, including today's.
- Today's note even if already `triaged: true`: compare with today's log in `_system/logs/triage/` and process only the new content.
If nothing is new, say so and stop.

## 2. Classify every item
Split captures into atomic items. For each, choose one or more:

| Item | Action |
|---|---|
| Event / what happened / feeling | Stays in the daily note. Extract any durable fact about the owner into `_me/` |
| Fact about the owner (preference, goal, routine, value, tool, plan) | Add to the right `_me/` note with provenance; answer and tick items in `Open Questions.md` |
| Idea | Search `02 Ideas/` first. Extend the existing note (append to `## Log`, add a source) or create one from `_system/templates/Idea.md` with `status: seed` and the owner's own words quoted |
| Project update / decision | Append to the project note's `## Log` / `## Decisions` |
| Person mentioned meaningfully | Create or extend `06 People/<Name>.md` |
| Knowledge / learning / reference | `05 Notes/` (or extend an existing note); educational material the owner saved also gets a row in `05 Notes/Learning/Knowledge Index.md` (topic, note, one-line takeaways, which current projects/ideas it applies to). Creator claims stay attributed claims, never facts about the owner |
| Explicit intention to act | Notion task proposal (step 3) |
| A decision the owner made (review feedback, a choice in conversation or the daily note: accept/reject, pick, park, price, design taste) | One row in `_me/Decisions.md`: their words quoted, your inferred why, confidence, source. If a pattern now has 2+ rows of evidence, add or extend a line in `_me/Motivations.md` (`inferred`, with evidence) and append it to its Confirmation queue |
| The owner confirms or rejects a Motivations line (`Confirm:` in the daily note or in conversation) | Mark it `stated (confirmed YYYY-MM-DD)` or strike it through with the date; remove it from the queue |
| A capture with `source: chatgpt` (a ChatGPT reply the owner dropped in) | Treat the ChatGPT text as reference material, like a web page: file the useful parts in `05 Notes/` or the related idea/project note, marked `(from ChatGPT, <date>)`. Never a fact about the owner, never a decision, never a task unless the owner wrote an intention themselves in the same note |
| `private:` line | Leave it. No Notion, no task, no external use. If the vault has a remote, a file with a `private:` line can't be committed (pre-commit guard): don't stage that file, and add to the brief "Move the `private:` line in <note> into `_private/`". Never move or edit it yourself |
| `Learned:` line | Append to `05 Notes/Learning/Learning Log.md` (the owner's words, dated, linked to the daily note) and add 1 recall question to `05 Notes/Learning/Recall Queue.md` (interval 1, due +1 day) |
| Something the owner engaged with today: a terminal session they ran (session lines in project `## Log`), a summary or research they asked for and replied to, a decision they made in conversation | Optionally 1 recall question each (max 2 per day) in `Recall Queue.md`, source = that interaction. **Never** from agent output the owner hasn't read |
| `Recall:` answers | Grade each against `Recall Queue.md`. Right → next interval (1→3→7→21→60 days); wrong → back to 1 day. Update `due` |

Rules: don't turn feelings or musings into tasks. "Maybe / thinking about" makes an idea, not a task. Keep the owner's wording when quoting.

## 3. Propose Notion tasks
Follow `_system/notion-bridge.md` exactly: dedup first, Status = Inbox, choose Executor (Me / Agent / Together), write the body template with a concrete Definition of done, relate the Project when obvious. Usually 0–8 tasks. Record each created task URL in the idea/project note it relates to (`notion:` or `## Log`).

Actively look for **agent-doable work** in what the owner wrote: research, drafts, comparisons, plans, code prototypes, summaries. Those become Executor = Agent tasks.

## 4. Close out
- Daily notes: set `triaged: true` (frontmatter only; never edit the body).
- Captures: set `triaged: true` and move them to `07 Archive/Inbox/YYYY-MM/` unchanged.
- Update `updated:` on any `_me` note you changed.
- Write `_system/logs/triage/YYYY-MM-DD.md` (append if it exists): input files; where each item went; Notion tasks created (title, executor, URL); facts added to `_me`; things skipped and why.
- Reflect: append 0–3 lessons to `_system/playbook.md`, or write "no new lesson" in the triage log.
- `git add -A && git commit -m "triage YYYY-MM-DD"`.

## 5. Report to the owner (short)
- Counts: notes processed, ideas new/updated, facts learned, tasks proposed (list titles; mark the Agent ones).
- "Approve in Notion: move to Next and tick Agent OK for the agent ones you want done."
- End with **2 recall questions** from `05 Notes/Learning/Recall Queue.md` (due today or overdue, oldest first), one line each. The owner answers under `Recall:` in their next daily note.
- At most 3 questions, the most valuable from `Open Questions.md` or ambiguities found today. Put the answers into `_me` with `(stated, conversation YYYY-MM-DD)`.
