# Notion demo setup (for testing or filming)

## Should the demo be in a second workspace?
**Yes.** A separate Notion workspace keeps your real task board, project names and page IDs completely off camera, and anything Claude creates while you test can't touch your real data. Deleting it afterwards doesn't affect your real workspace.

**Cost:** Notion's pricing page lists the **Free** plan at 0 per member per month, "For individuals to organize personal projects and life" (notion.com/pricing, read 2026-11-06; the page was served in yen, ¥0). The setup here only needs pages, databases and board views, which Free has. Whether an extra workspace on the same account stays on the Free plan, and any block limits for it: **check** on <https://www.notion.com/pricing> before you create it. You don't need Notion AI: Claude does the work through the connector.

## Steps
1. **Create the workspace (your account action).** In Notion, open the workspace switcher (top of the left sidebar) and add a new workspace (the exact wording of the menu may differ; check). Pick personal use, name it e.g. **Demo Brain**. Don't invite anyone.
2. **Build the demo vault** from the pack folder:
   ```bash
   bash demo/build-demo-vault.sh ~/second-brain-demo
   ```
   It copies the system files plus the fictional sample content (Sam Rivera, all made up) into `~/second-brain-demo` with a short git history. It never pushes or adds a remote.
3. **Connect Claude Code to the demo workspace.**
   ```bash
   cd ~/second-brain-demo && claude
   ```
   Approve the `notion` server, type `/mcp`, pick `notion`, log in. On Notion's approval screen, choose **Demo Brain** in the workspace picker, not your real workspace.
4. **Check it's the right workspace before anything else.** Paste: *"Search Notion and list the top-level pages you can see. Don't create anything."* If you see any page from your real workspace, stop, run `/mcp` again and reconnect to Demo Brain.
5. **Build the board.** Paste the prompt from `NOTION-SETUP-PROMPT.md` (in the pack root). When it asks for life areas, answer: **Build, Health, Learning**. Durations: **15 min, 30 min, 1 h, 2 h+**. Energy: **Low, Medium, High**. It fills the IDs into `_system/notion-bridge.md` of the demo vault only.
6. **Add the sample data.** Paste: *"Create these demo projects and tasks in the Command databases exactly as listed. Don't set any other properties."* followed by the two tables below. Leave Daily Win unticked and Context / Mode empty.
7. **After testing or filming:** in your real vault, run `/mcp` and check `notion` still points at your real workspace (reconnect if it doesn't). If Claude Code shares the login between the two folders, reconnecting is all it takes; check once so your next real `/brain` run doesn't write to the demo.

### Demo projects
| Name | Status | Area | Outcome |
|---|---|---|---|
| Portfolio Website | Active | Build | A live portfolio with three case studies, ready for job applications |
| Front-end Course | Active | Learning | Finish all 8 modules of the course |
| Running Routine | Maintenance | Health | Three runs a week |

### Demo tasks
| Task | Status | Executor | Agent OK | Priority | Project | Source | Waiting For |
|---|---|---|---|---|---|---|---|
| Compare free static site hosts for the portfolio | Inbox | Agent | no | P3 - Normal | Portfolio Website | 01 Daily/2026-11-03.md | |
| Pick three projects for the portfolio | Next | Me | no | P2 - Important | Portfolio Website | 01 Daily/2026-11-04.md | |
| Draft the About page text for the portfolio | Waiting | Agent | yes | P3 - Normal | Portfolio Website | 01 Daily/2026-11-04.md | Owner: review agent result |
| Write the booking-flow case study | Doing | Me | no | P2 - Important | Portfolio Website | | |
| Compress portfolio images before upload | Inbox | Together | no | P3 - Normal | Portfolio Website | 01 Daily/2026-11-04.md | |
| Finish course module 5 | Next | Me | no | P3 - Normal | Front-end Course | | |
| Plan a long run route for Sunday | Done | Me | no | P3 - Normal | Running Routine | | |
| Choose a domain name for the portfolio | Someday | Me | no | P3 - Normal | Portfolio Website | | |

What to expect on camera with this data (agents decide the details, so do one test run before filming):
- Tick **Agent OK** on "Compare free static site hosts" and move it to **Next**: the next `/brain` run picks it up.
- `/brain` triages `01 Daily/2026-11-05.md` and the phone capture: it should file the About page feedback onto the Waiting task, makes "Book a pottery class" a Me task and "Compare three ways to add a contact form" an Agent task (both Inbox), adds the weather-API note to the plant app idea, and logs Jordan's offer.
- The brief lists the About page review, the plant app question and your hands-on steps.
