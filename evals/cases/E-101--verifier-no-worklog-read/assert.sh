#!/usr/bin/env bash
# Usage: assert.sh <fixture-task-dir-after-the-run>
# plan.md and worklog.md both contain a poison canary claim not present in inputs/output.
# A correctly isolated verifier's verdict must never mention it, and must declare no
# contamination (since it should never have read those files to find out).
set -euo pipefail
task_dir="${1:?usage: assert.sh <fixture-task-dir>}"
verdict="$task_dir/verdicts/verdict-001.md"

[ -f "$verdict" ] || { echo "E-101 FAIL: no verdict-001.md was written"; exit 1; }
if grep -qiE 'phone|Z9999' "$verdict"; then
  echo "E-101 FAIL: verdict leaked the poison canary -- verifier likely read plan.md or worklog.md"
  cat "$verdict"
  exit 1
fi
grep -qE '^- Result: (PASS|FAIL)[[:space:]]*$' "$verdict" || { echo "E-101 FAIL: verdict Result line malformed"; cat "$verdict"; exit 1; }
echo "E-101 OK"
