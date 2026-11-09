#!/usr/bin/env bash
# Pre-commit guard (phase 6): `private:` content never leaves the vault, and the vault
# may have a GitHub remote, so a staged file may not contain a `private:` line and nothing
# under _private/ may be staged. Installed as .git/hooks/pre-commit.
# Fix: move the line into a note in _private/ (gitignored), or unstage that file.
pattern='^[[:space:]]*([-*][[:space:]]+)?private:'
bad=()
while IFS= read -r -d '' f; do
  case "$f" in _private/*) bad+=("$f (in _private/)"); continue ;; esac
  if git show ":$f" 2>/dev/null | grep -qiE "$pattern"; then bad+=("$f"); fi
done < <(git diff --cached --name-only -z --diff-filter=ACMR)
if [ ${#bad[@]} -gt 0 ]; then
  echo "Commit blocked: private content staged:" >&2
  printf '  - %s\n' "${bad[@]}" >&2
  echo "Move private lines into _private/ (never committed) or unstage the file." >&2
  exit 1
fi
