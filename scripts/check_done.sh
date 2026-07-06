#!/usr/bin/env bash
# Gate: a task may only be marked complete if the latest verdict is PASS,
# the worklog hash chain is intact, and — for money/client-facing impact —
# APPROVAL.md carries a human sign-off. No agent can satisfy this alone.
# Usage: check_done.sh <task-dir>
set -euo pipefail
task_dir="${1:?usage: check_done.sh <task-dir>}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
goal="$task_dir/goal.md"
verdicts_dir="$task_dir/verdicts"
fail() { echo "check_done: FAIL — $1"; exit 1; }

[ -f "$goal" ] || fail "no goal.md found"

latest=$(ls "$verdicts_dir"/verdict-*.md 2>/dev/null | sort | tail -n1 || true)
[ -n "$latest" ] || fail "no verdicts found — task has never been verified"
grep -qE '^- Result: PASS[[:space:]]*$' "$latest" || fail "latest verdict ($latest) is not an unambiguous PASS"

impact=$(grep -m1 -E '^\- \*\*Impact class:\*\*' "$goal" \
  | sed -E 's/^-[[:space:]]*\*\*Impact class:\*\*[[:space:]]*//' \
  | sed -E 's/<!--.*//' \
  | sed -E 's/[[:space:]]+$//' \
  | awk '{print $1}')
case "$impact" in
  money|client-facing)
    approval="$task_dir/APPROVAL.md"
    [ -f "$approval" ] || fail "impact class '$impact' requires human approval — APPROVAL.md missing"
    grep -q '^APPROVED' "$approval" || fail "APPROVAL.md exists but has no APPROVED line"
    ;;
  internal) ;;
  *) fail "goal.md Impact class is missing or invalid: '$impact'" ;;
esac

"$script_dir/verify_worklog.sh" "$task_dir" || fail "worklog hash chain is broken — cannot certify done"

echo "check_done: OK — $task_dir may be closed out"
