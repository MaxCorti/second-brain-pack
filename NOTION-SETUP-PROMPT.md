# Notion setup prompt

Paste the text in the box below into Claude (Claude Code in this vault folder, or claude.ai) **with the Notion connector turned on**. Claude will show you a plan first and ask before it creates anything. It takes about 5 minutes.

Before you paste:
- In Claude Code, the Notion connector comes from `.mcp.json` in this folder. Run `/mcp`, pick `notion` and log in to the Notion workspace you want to use.
- Want to try it on a test workspace first? Create a separate free Notion workspace and log the connector in to that one.

---

> You are setting up the Notion side of my second brain. Use the Notion connector. Ask me before creating anything, and show me the plan first.
> 1. Create a page called **Command** (or a name I choose). Inside it, two databases:
>    - **Projects**: Name, Status (Active / Maintenance / Paused / Complete), Area (select, ask me for my life areas), Outcome (text).
>    - **Tasks**: Task (title), Status (Inbox / Next / Doing / Waiting / Done / Someday), Executor (Me / Agent / Together), Agent OK (checkbox), Approved by (Me / policy), Source (text), Project (relation to Projects), Priority (P1 Critical / P2 Important / P3 Normal), Waiting For (text), Due (date), Scheduled (date), Duration (select, ask me), Energy (select, ask me).
> 2. Add board views: Tasks grouped by Status; "Agent queue" filtered to Status = Next and Agent OK ticked; "Waiting on me" filtered to Status = Waiting.
> 3. Then open `_system/notion-bridge.md` in my vault and replace the placeholders `<COMMAND_PAGE_ID>`, `<TASKS_DATA_SOURCE>` and `<PROJECTS_DATA_SOURCE>` with the real IDs. Don't put those IDs anywhere else.
> 4. My rules, write them on the Command page: agents create tasks only with Status = Inbox; only I tick Agent OK; no fake deadlines; agents never change a project's status.

---

After it's done:
1. Open Notion and check the **Tasks** board has the columns Inbox, Next, Doing, Waiting, Done, Someday.
2. Open `_system/notion-bridge.md` and check the three placeholders are now filled in.
3. If you'll ever make your vault public, remember that file now holds your Notion IDs. Keep the vault repo **private**.
