#!/usr/bin/env bash
# Run this YOURSELF to approve a task that needs human sign-off — this script is
# deliberately something a person runs, not something Claude runs on your behalf.
# No agent has Write/Edit access to APPROVAL.md (see .claude/settings.json's deny
# rules); this script doesn't create a backdoor around that restriction, it just
# gives you a friendlier way to do the one thing only you can do — same as
# opening a text editor and typing a line would be, just guided.
#
# Usage: scripts/approve.sh <task-dir>
set -euo pipefail
task_dir="${1:?usage: scripts/approve.sh <task-dir>}"
goal="$task_dir/goal.md"
approval="$task_dir/APPROVAL.md"

[ -f "$goal" ] || { echo "No goal.md found at $task_dir — is that the right task folder?"; exit 1; }

if [ -f "$approval" ] && grep -q '^APPROVED' "$approval"; then
  echo "This task is already approved:"
  cat "$approval"
  exit 0
fi

echo "=================================================================="
echo " You are about to approve:  $task_dir"
echo "=================================================================="
echo
echo "--- What this task was asked to produce (goal.md) ---"
awk '/^## 1\. End State/{f=1;next}/^## /{f=0}f' "$goal" | sed '/^$/d'
echo
echo "--- House rules it had to follow ---"
awk '/^## 3\. House Rules/{f=1;next}/^## /{f=0}f' "$goal" | sed '/^$/d'
echo

latest=$(ls "$task_dir"/verdicts/verdict-*.md 2>/dev/null | sort | tail -n1 || true)
if [ -n "$latest" ]; then
  echo "--- Independent reviewer's verdict ---"
  grep '^- Result:' "$latest" || true
  echo "(full detail in $latest)"
else
  echo "WARNING: no reviewer verdict found yet. This task has not been checked."
  echo "Approving now would skip that check — you probably want to wait."
fi
echo

read -rp "Type your name to approve, or press Ctrl-C to cancel: " approver
if [ -z "$approver" ]; then
  echo "No name entered — not approving. Nothing was written."
  exit 1
fi

echo "APPROVED - $approver - $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$approval"
echo
echo "Done. Wrote $approval — this task can now be closed out."
