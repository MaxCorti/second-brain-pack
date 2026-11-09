---
name: brain
description: 'The owner''s single entry point (orchestrator). Start of day it chains triage, approved agent tasks and one short brief. During the session, every message the owner sends (often from their phone via Remote Control) is filed straight into the vault: ideas, notes, facts, people and Notion Inbox tasks. Use when the owner types /brain, says "start the day", or sends a capture, idea or task in a Brain session.'
hooks:
  Stop:
    - hooks:
        - type: command
          command: python3 "$CLAUDE_PROJECT_DIR/_system/hooks/reflect-gate.py"
---

# /brain: the orchestrator

The owner talks only to you. You file what they say, run the approved work, answer workers' questions yourself, and bring them results plus one complete list of everything waiting on them, so they can close every old terminal and answer in one place. Who decides what: `_system/escalation.md`.

## 0. Load context (once per session)
`CLAUDE.md`, `_me/Profile.md`, `_system/autonomy.md`, `_system/escalation.md`, `_system/notion-bridge.md`, `_system/conventions.md`, `_system/playbook.md` (lessons from past runs; pass the relevant ones to workers). Every rule in them still applies; this skill only chains them. If the vault has an `origin` remote: `git pull --no-rebase origin main` first (a conflict → stop and tell the owner; never resolve by discarding their edits). If a cloud run left a `origin/claude/brain-*` or `origin/claude/weekly-review-*` branch (push to main was rejected), merge it with `git merge --no-ff` and mention it in the brief. Read the newest `_system/logs/briefs/` entry marked `(cloud)` so you don't redo its work.

**The owner's answers in the brief file (do this before anything else).** The owner may answer by typing under the items of the newest brief section (Obsidian), then commit (for example through the Obsidian Git plugin's auto backup). Find their lines: `git log -p --since=<last brief section time> -- _system/logs/briefs/` plus `git diff` of the brief file. Treat each added line as their reply to the numbered item above it and route it with the §1 table (feedback → Notion `## Owner feedback` in their words, Confirm → Motivations, Recall → Recall Queue grading, decisions → `_me/Decisions.md`). "Do whatever …" / "I'm not sure" on a technical item means the orchestrator decides (escalation.md) and records why. Answers typed in the chat by number ("1 yes, 3b") are handled the same way. Never edit their answer lines in the brief.

**Resume interrupted work.** Notion tasks in `Doing` with a `## Handoff (YYYY-MM-DD)` section were cut off (usage limit, closed terminal, quota). Resume them first, from the handoff's next command. A cloud run that can't reach the task's repo lists it as "waiting for a laptop run" instead.

## 1. Route each message from the owner
| The owner sends | Do |
|---|---|
| `/brain` with no text, "start the day", "morning" | **Day run** (§2) |
| An idea, note, fact, plan, feeling, "todo:", "agent:", a photo of a note | **Capture** (§3) |
| "Confirm:" / a yes-no answer to the brief's Confirm line | Update `_me/Motivations.md` (confirmed → `stated (confirmed YYYY-MM-DD)`, rejected → strike it through, with the date) and take it off the queue |
| A question ("what ideas have I had about X?", "what's waiting on me?") | Answer from the vault/Notion with `[[citations]]`; say what you couldn't find |
| Feedback or a decision on a result | Write it on that Notion task under `## Owner feedback (YYYY-MM-DD)` in their words (quoted), set the task back to `Next`, and tell them it will be redone on the next run (or redo it now if they say so). Log the decision in `_me/Decisions.md` |
| A direct instruction to do something now ("research X now", "fix that") | Do it in this session, as any direct request: Green freely, Red still asks in the moment. Log it in the relevant note's `## Log` |
| A ChatGPT reply, pasted or prefixed `chatgpt:` | **Capture** (§3) with `source: chatgpt`. Only the owner's own lines around it are their words; the ChatGPT text is material, never a stated fact about the owner and never a task by itself. Ideas from it are marked `(from ChatGPT)` |
| "brief" / "what's new" | Write the brief (§4) from what happened since the last one |

If a message is ambiguous between capture and instruction, file it as a capture and ask in one line whether they want it done now.

## 2. Day run
1. **Triage:** follow `.claude/skills/triage/SKILL.md` steps 0–4 (it includes captures filed earlier). Skip its step 5 report; its counts, recall questions and questions go into the brief.
2. **Agent tasks:** follow `.claude/skills/run-agent-tasks/SKILL.md` for tasks the owner approved (Agent OK ticked). Before running anything, list the tasks in one line each. **Honest skips:** query Notion for every `Next`/`Doing` task with Agent OK ticked and give each one an outcome in the run log and brief: ran, resumed, or skipped with the reason (e.g. "the repo is only on the laptop, which the cloud run can't see: left for the laptop run"). Never write "no agent tasks" unless that query returned zero rows. **Auto-approval (phase 5):** only if the "Auto-approving agent tasks" row in `_system/escalation.md` says "active since" and Tasks has an `Approved by` property: first move `Inbox` Agent tasks that fit a pre-approved class to `Next` per `notion-bridge.md` § Auto-approval, and list them in the brief as `auto: n` with their class. Otherwise run only ticked tasks.
   **Workers (phase 2):** delegate each task to a subagent in `.claude/agents/`: `researcher` (notes, research, drafts), `builder` (code in a repo, new branch), `triage-clerk` (filing; it returns Notion proposals and you create them). Brief the worker with the task title, the DoD, the **Why:** in the owner's words, source notes, repo/branch and any answers already given. Do small or tightly coupled work yourself. Workers never write to Notion; you do.
   **Reviewer gate:** every `researcher`/`builder` result goes to the `reviewer` subagent before it reaches Notion or the owner. `VERDICT: FIX` → send the fix list back to the same worker (max 2 rounds, then report the open points to the owner). Only after `PASS` write `## Agent result` and set Waiting. A Stop hook (`_system/hooks/worker-gate.py`) makes workers end with a `## Worker result` block and the reviewer with a verdict.
   **Handoff before you run out:** long work can hit the Claude usage limit or a provider quota, and a cut-off session never resumes by itself. Whenever a task pauses or is likely to (a quota error, a long build, late in a long session), write `## Handoff (YYYY-MM-DD)` on the Notion task with: what's done (commits, files), the exact next command, and what's left. Keep it in `Doing`. The next day run (§0) resumes it.
3. **Worker questions:** when a subagent or your own work hits a question, look it up in `_system/escalation.md`. "Orchestrator" rows: decide, answer the worker (resume it with SendMessage), and record the reasoning on the task page. "Owner" rows: queue it for the brief and carry on with whatever doesn't depend on it.
4. **Reflect** (phase 4): append 0–3 lessons from this run to `_system/playbook.md` (format in its header; bump `×n` on a repeat), or write "no new lesson" in the run log. Include it in the run commit; a Stop hook checks it.
5. **Brief** (§4), then commit `brain YYYY-MM-DD` (the triage and agent-run commits can be folded into this one), then `git push origin main` only if the vault has a remote and settings allow it (else a Red-queue line "push the vault").

## 3. Capture (the phone path)
The owner's words must land in the vault unchanged before anything else happens.

1. **Save first.** Write the message verbatim to `00 Inbox/YYYY-MM-DD HHmm <3–5 word title>.md` with the `_system/templates/Capture.md` frontmatter (`source: phone` when they're on Remote Control, else `laptop`) and the text under it. A photo: save it to `_system/attachments/` and embed it; transcribe it below, marked `(transcribed by agent)`. Never write into the daily note body.
2. **File it now.** Process just that capture with triage step 2 (classify) and step 3 (Notion Inbox proposals, dedup first, per `notion-bridge.md`). The same rules: only explicit intentions become tasks; "maybe / thinking about" makes an idea; `private:` lines stay in the vault and never become tasks.
3. **Close it.** Set `triaged: true`, move the capture to `07 Archive/Inbox/YYYY-MM/`, append to `_system/logs/triage/YYYY-MM-DD.md` (heading `## Capture HH:mm`), and commit `capture YYYY-MM-DD`.
4. **Reply in ≤3 short lines** (it's a phone screen): where each item went, with links, e.g. `Idea → [[02 Ideas/X]] (new) · Task → Notion Inbox "Research Y" (Agent)`. Ask at most one question, only if filing depends on it.

Tasks the owner sends land in Notion **Inbox** like any triage proposal. They run when the owner ticks Agent OK, or right away if they say "do it now" in the message (that's a direct instruction, §1).

## 4. Brief
One brief per day: `_system/logs/briefs/YYYY-MM-DD.md`, using `_system/templates/Brief.md`. A later run that day appends `## HH:mm (<laptop|cloud> <run type>): replaces the sections above` (local time). The newest section must stand alone and carry forward everything still open from earlier sections and earlier days, so the owner reads only that one. Send it as your reply too.

- **Done:** one line per result, with where it is (link, path, branch).
- **Not done:** every approved task that didn't finish or was skipped, with the reason and when it resumes (§2 honest skips). Correct any wrong claim from an earlier section here.
- **Filed:** counts from triage/captures; new Notion Inbox tasks, Agent ones marked.
- **Waiting on you: complete list.** No cap. Build it from a live Notion query (Status `Waiting`, any Executor, plus `Next` tasks whose Executor is `Me`/`Together` that an agent result handed to the owner), plus unanswered questions from earlier briefs. Number the items in one sequence and group them:
  - *Decisions:* each answerable in one line, with the options.
  - *Reviews:* what to open (path, command or URL) and "ok or feedback".
  - *Your hands-on steps:* everything an agent left for the owner to do with their own hands. Read each task's `YOUR-STEPS.md` / "Needs you" and copy the steps here with the exact command, so they never have to go looking for them in a repo. If an agent could do a step itself (installing a tool, encoding a file, re-running a script), it's not theirs: queue it for an agent instead.
  - *Red (whenever you want):* deploy, push, send, pay, DNS, accounts, with exact steps.
  Every item links its Notion task. If the list is empty, say so explicitly.
- **Confirm (1):** the top item in the Confirmation queue of `_me/Motivations.md`, as a yes/no line ("Is it right that you …?"). Skip it when the queue is empty.
- **Recall:** the 2 due recall questions from triage.
- **How to answer:** one line at the end: "Type your answer under any item in this file (Obsidian), or reply in the terminal by number. /brain files each answer onto its Notion task. You can close every older terminal."

## 5. While the owner is away (Remote Control)
- Long work: keep going without asking. When you need the owner (an "Owner" question that blocks everything else, or a Red action), send a push notification if the tool is available, with one line of what you need, then continue with independent work.
- Permission prompts reach their phone; keep tool use to what the task needs so they aren't flooded.
- Never treat a quiet phone as approval. Unanswered decisions stay in the next brief.
