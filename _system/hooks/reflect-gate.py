#!/usr/bin/env python3
"""Reflection gate (phase 4 of the second-brain system).

Runs as a Stop hook in the frontmatter of the run skills (/brain, /triage,
/run-agent-tasks, /weekly-review). If the latest vault commit is a run commit made
in the last 20 minutes and the run didn't add to _system/playbook.md or say
"no new lesson" in its run log, it asks once for the reflection step.

Fails open: any error, a second attempt (stop_hook_active) or no recent run commit
lets the session stop.
"""
import json
import os
import re
import subprocess
import sys
import time

RUN = re.compile(r"^(brain|agent-run|triage|weekly-review)\b")
WINDOW = 20 * 60


def git(*args, cwd):
    return subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, timeout=10).stdout.strip()


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}
    if data.get("stop_hook_active"):
        return
    vault = os.environ.get("CLAUDE_PROJECT_DIR") or data.get("cwd") or "."
    line = git("log", "-1", "--format=%ct|%s", cwd=vault)
    if "|" not in line:
        return
    ts, subject = line.split("|", 1)
    if not RUN.match(subject) or time.time() - int(ts) > WINDOW:
        return
    files = git("show", "--name-only", "--format=", "HEAD", cwd=vault).splitlines()
    if "_system/playbook.md" in files:
        return
    diff = git("show", "--format=", "HEAD", "--", "_system/logs", cwd=vault)
    if "no new lesson" in diff.lower():
        return
    print(json.dumps({
        "decision": "block",
        "reason": "Reflection step: append 0-3 lessons from this run to _system/playbook.md "
        "(format in its header), or write 'no new lesson' in the run log, then commit "
        "'playbook YYYY-MM-DD'.",
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
