#!/usr/bin/env bash
# Builds a working demo vault: the pack's system files + the fictional sample content in
# demo/vault/, as a fresh local git repo with a short, back-dated history.
# Usage: bash demo/build-demo-vault.sh [target folder]   (default: ~/second-brain-demo)
# It only writes inside the target folder, refuses to overwrite one that exists, and never
# adds a remote or pushes anything.
set -euo pipefail

PACK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$HOME/second-brain-demo}"

if [ -e "$TARGET" ]; then
  echo "Target $TARGET already exists. Pick another folder or remove it yourself." >&2
  exit 1
fi
mkdir -p "$TARGET"

# 1. Pack system files (tracked files only, without demo/ and the owner-only notes).
cd "$PACK"
git ls-files -z 2>/dev/null | while IFS= read -r -d '' f; do
  case "$f" in demo/*|YOUR-STEPS.md|CLEANING-REPORT.md) continue ;; esac
  mkdir -p "$TARGET/$(dirname "$f")"
  cp "$f" "$TARGET/$f"
done
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  echo "No tracked files found: commit the pack first (git add -A && git commit)." >&2
  exit 1
fi
mkdir -p "$TARGET/_private"

# 2. A fresh repo with a demo identity, so the git log shows a believable history.
cd "$TARGET"
git init -q -b main
cp _system/hooks/private-guard.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
g() { git -c user.name="Sam (demo)" -c user.email="demo@example.com" "$@"; }
commit_at() { # date message
  GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1" g commit -q -m "$2"
}

git add -A
commit_at "2026-11-02T09:00:00" "start my second brain"

DEMO="$PACK/demo/vault"
copy_demo() { for f in "$@"; do mkdir -p "$(dirname "$f")"; cp "$DEMO/$f" "$f"; done; }

copy_demo "_me/Profile.md" "_me/Open Questions.md" "_me/Goals.md" "ABOUT-THIS-DEMO.md"
git add -A
commit_at "2026-11-02T21:00:00" "interview 2026-11-02"

copy_demo "01 Daily/2026-11-03.md" "01 Daily/2026-11-04.md"
git add -A
commit_at "2026-11-04T18:30:00" "vault backup: 2026-11-04 18:30:00"

copy_demo "02 Ideas/Plant Watering Reminder App.md" "02 Ideas/Weekly Meal Prep Planner.md" \
  "03 Projects/Portfolio Website.md" "04 Areas/Build.md" "04 Areas/Health.md" "04 Areas/Learning.md" \
  "06 People/Jordan.md" "_me/Motivations.md" \
  "05 Notes/Learning/Learning Log.md" "05 Notes/Learning/Recall Queue.md" \
  "_system/logs/triage/2026-11-04.md"
git add -A
commit_at "2026-11-04T19:20:00" "triage 2026-11-04"

copy_demo "05 Notes/Portfolio About Page Draft.md" "_system/logs/briefs/2026-11-04.md"
git add -A
commit_at "2026-11-04T19:40:00" "brain 2026-11-04"

copy_demo "01 Daily/2026-11-05.md" "00 Inbox/2026-11-05 0812 Plant App Weather Data.md"
git add -A
commit_at "2026-11-05T08:15:00" "vault backup: 2026-11-05 08:15:00"

echo "Demo vault ready: $TARGET"
echo "Next: open it in Obsidian, connect Notion to your demo workspace (demo/NOTION-DEMO-SETUP.md), then: cd \"$TARGET\" && claude"
git log --oneline
