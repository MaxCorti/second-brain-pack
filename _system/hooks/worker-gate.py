#!/usr/bin/env python3
"""Stop gate for vault subagents (phase 2 of the second-brain system).

Runs as a frontmatter Stop hook (Claude Code turns it into SubagentStop for that agent).
Usage: worker-gate.py worker | reviewer

worker   : the final message must contain a "## Worker result" block with
           "Done:", "DoD check:" and "Questions:" lines, so the orchestrator can hand it
           to the reviewer.
reviewer : the final message must contain "VERDICT: PASS" or "VERDICT: FIX".

Fails open: any error, or a second attempt (stop_hook_active), lets the agent stop.
"""
import json
import sys

REQUIRED = {
    "worker": ["## Worker result", "Done:", "DoD check:", "Questions:"],
    "reviewer": [],
}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "worker"
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    if data.get("stop_hook_active"):
        return
    msg = data.get("last_assistant_message") or ""
    if not isinstance(msg, str):
        msg = json.dumps(msg)

    if mode == "reviewer":
        missing = [] if ("VERDICT: PASS" in msg or "VERDICT: FIX" in msg) else ["VERDICT: PASS or VERDICT: FIX"]
    else:
        missing = [k for k in REQUIRED["worker"] if k not in msg]

    if missing:
        print(json.dumps({
            "decision": "block",
            "reason": "Before finishing, end with the required block (see your agent file). Missing: "
            + ", ".join(missing),
        }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
