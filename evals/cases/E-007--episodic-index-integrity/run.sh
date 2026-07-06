#!/usr/bin/env bash
# E-007: the episodic index rebuild must (a) correctly index the real archived
# dry-run task (9 worklog rows, 3 verdicts, PASS), and (b) refuse to index a
# task whose hash chain has been tampered with.
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$repo_root"

python scripts/index_rebuild.py >/dev/null

python - <<'PYEOF'
import sqlite3
con = sqlite3.connect("memory/episodes.db")
row = con.execute("SELECT * FROM tasks WHERE task_id='2026-07-06--dry-run'").fetchone()
assert row is not None, "E-007 FAIL: dry-run task not indexed"
n_worklog = con.execute("SELECT COUNT(*) FROM worklog_entries WHERE task_id='2026-07-06--dry-run'").fetchone()[0]
assert n_worklog == 9, f"E-007 FAIL: expected 9 worklog rows, got {n_worklog}"
n_verdicts = con.execute("SELECT COUNT(*) FROM verdicts WHERE task_id='2026-07-06--dry-run'").fetchone()[0]
assert n_verdicts == 3, f"E-007 FAIL: expected 3 verdicts, got {n_verdicts}"
print("E-007: dry-run task correctly indexed (9 worklog rows, 3 verdicts)")
PYEOF

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp -r archive/tasks/2026-07-06--dry-run "$tmp/broken_task"
sed -i 's/ITERATION 1\/3 START/TAMPERED/' "$tmp/broken_task/worklog.md"

if python scripts/index_task.py "$tmp/broken_task" >/dev/null 2>&1; then
  echo "E-007 FAIL: index_task.py indexed a task with a tampered hash chain"
  exit 1
fi

echo "E-007 OK"
