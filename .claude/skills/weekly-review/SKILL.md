---
name: weekly-review
description: Weekly synthesis of the owner's vault and Notion. Summarises the week, refreshes project snapshots, ranks the idea backlog, flags stale tasks, spots patterns, suggests better use of paid tools and updates _me. Use when the owner asks for a weekly review or what to focus on next.
hooks:
  Stop:
    - hooks:
        - type: command
          command: python3 "$CLAUDE_PROJECT_DIR/_system/hooks/reflect-gate.py"
---

# /weekly-review

1. Run `/triage` first if there are untriaged captures.
2. Read the last 7 daily notes, the week's triage and agent-run logs, `_me/Goals.md`, `_me/Skills and Tools.md`.
3. **Projects:** query Notion Projects; refresh `status`/`synced` in each `03 Projects/` note; create notes for new projects; move Complete ones to `07 Archive/`.
4. **Tasks:** query Notion Tasks for Inbox items older than 7 days, `Waiting` items waiting on the owner, and Agent tasks awaiting review. List them; don't change them.
5. **Ideas:** go through `02 Ideas/`. Rank the top 3 worth a next step against the owner's goals (say why), and suggest one Executor = Agent research or prototype task for each. Propose those tasks in Notion (Status Inbox) only if the owner agrees during the review.
6. **Patterns:** energy/mood trends, recurring worries or themes, promises made to people (link `06 People/`). Mark everything `inferred`.
7. **Paid tools:** 1–3 concrete ways to use the owner's paid plans (listed in `_me/Skills and Tools.md`) on their current goals.
8. Write `01 Daily/Reviews/YYYY-Www.md` from `_system/templates/Weekly Review.md`. Fill `## Reflection` with the 3 questions for the owner to answer (don't answer them for them), and `## Creative slot` with one 60–90 min suggestion built from `02 Ideas/` (say which idea and why). Include the week's `Learned:` lines and the recall hit rate from `05 Notes/Learning/Recall Queue.md`.
8b. **Curator (phase 4):** run the `curator` subagent. It reads `_system/playbook.md` and the week's logs and writes `_system/proposals/YYYY-Www-diffs.md`: at most 5 proposed diffs to skills, templates or conventions, each with the lessons behind it. Put them in the review under `## Proposed system changes`, numbered. The owner accepts or rejects each ("accept 1, 3"). Apply only the accepted ones, quote their answer in the proposals file, and mark the source lessons `→ applied YYYY-MM-DD`. `autonomy.md`, `escalation.md` and `.claude/settings.json` are never in a batch.
9. Update `_me/` with durable insights (sourced; inferred unless the owner confirms). Commit: `weekly-review YYYY-Www`.
10. Report: 5–10 lines plus up to 3 questions.
