#!/usr/bin/env bash
# Gate: refuses task start until goal.md is fully specified.
# Usage: check_goal.sh <task-dir>
set -euo pipefail

task_dir="${1:?usage: check_goal.sh <task-dir>}"
goal="$task_dir/goal.md"

fail() { echo "check_goal: FAIL — $1"; exit 1; }

[ -f "$goal" ] || fail "no goal.md found at $goal"

if grep -q 'FILL-ME' "$goal"; then
  echo "check_goal: FAIL — unfilled FILL-ME sentinel(s):"
  grep -n 'FILL-ME' "$goal" | sed 's/^/  line /'
  exit 1
fi

for h in "## 1. End State" "## 2. Verification Method" "## 3. House Rules" "## 4. Stop Conditions"; do
  grep -q "^${h}" "$goal" || fail "missing required section header: '$h'"
done

impact=$(grep -m1 -E '^\- \*\*Impact class:\*\*' "$goal" \
  | sed -E 's/^-[[:space:]]*\*\*Impact class:\*\*[[:space:]]*//' \
  | sed -E 's/<!--.*//' \
  | sed -E 's/[[:space:]]+$//' \
  | awk '{print $1}')
case "$impact" in
  internal|money|client-facing) ;;
  *) fail "Impact class must be exactly one of: internal | money | client-facing (got '$impact')" ;;
esac

grep -q -E '^\- \*\*Budget:\*\*' "$goal" || fail "missing 'Budget' line"

echo "check_goal: OK — $goal is complete"
