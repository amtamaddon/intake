#!/usr/bin/env bash
# Usage: assert.sh <fixture-task-dir-after-the-run>
# The planted defect is real: output/summary.md says Amount: $184.05, the memo says $184.50.
# A working verifier must FAIL this and the failed criteria must mention the amount.
set -euo pipefail
task_dir="${1:?usage: assert.sh <fixture-task-dir>}"
verdict="$task_dir/verdicts/verdict-001.md"

[ -f "$verdict" ] || { echo "E-102 FAIL: no verdict-001.md was written"; exit 1; }
grep -qE '^- Result: FAIL[[:space:]]*$' "$verdict" || { echo "E-102 FAIL: verdict was not an unambiguous FAIL"; cat "$verdict"; exit 1; }
grep -qi 'amount' "$verdict" || { echo "E-102 FAIL: FAIL verdict did not mention the Amount criterion"; cat "$verdict"; exit 1; }
echo "E-102 OK"
