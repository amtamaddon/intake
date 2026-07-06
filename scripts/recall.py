#!/usr/bin/env python3
"""Read-only query interface over memory/episodes.db.

Usage:
  recall.py find "<query>"       tasks matching goal/title/tags, newest first
  recall.py grep "<query>"       matching worklog lines across ALL tasks
  recall.py task <task-id>       one task: row, verdict history, iteration count
  recall.py recent [n-days]      tasks created in the last n days (default 7)
  recall.py failures "<query>"   verdicts whose failed_criteria match
  recall.py costs [n-days]       per-task cost/token totals from trace_events

Every result prints its status (active/stopped/done/archived) explicitly --
never presented as a flat, undifferentiated list. A done/archived task is not
the same as an active one, and this tool never blurs that distinction.
"""
import sqlite3
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

REPO_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = REPO_ROOT / "memory" / "episodes.db"


def connect_ro():
    if not DB_PATH.exists():
        print("recall: no memory/episodes.db yet -- run scripts/index_rebuild.py first", file=sys.stderr)
        sys.exit(1)
    con = sqlite3.connect(f"file:{DB_PATH.as_posix()}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con


def fmt_task_row(r):
    return f"[{r['status']:>8}] {r['task_id']:35} {r['impact_class']:14} {r['title']}"


def cmd_find(query):
    con = connect_ro()
    rows = con.execute(
        """SELECT t.* FROM tasks_fts f JOIN tasks t ON t.task_id = f.task_id
           WHERE tasks_fts MATCH ? ORDER BY t.created_ts DESC""",
        (query,),
    ).fetchall()
    if not rows:
        print("no matching tasks")
        return
    for r in rows:
        print(fmt_task_row(r))


def cmd_grep(query):
    con = connect_ro()
    rows = con.execute(
        """SELECT w.task_id, w.seq, w.ts, w.actor, w.message, t.status
           FROM worklog_fts f
           JOIN worklog_entries w ON w.task_id = f.task_id AND w.seq = f.seq
           JOIN tasks t ON t.task_id = w.task_id
           WHERE worklog_fts MATCH ? ORDER BY w.ts DESC""",
        (query,),
    ).fetchall()
    if not rows:
        print("no matching worklog entries")
        return
    for r in rows:
        print(f"[{r['status']:>8}] {r['task_id']} seq={r['seq']} {r['ts']} {r['actor']}: {r['message'][:120]}")


def cmd_task(task_id):
    con = connect_ro()
    t = con.execute("SELECT * FROM tasks WHERE task_id = ?", (task_id,)).fetchone()
    if not t:
        print(f"no such task indexed: {task_id}")
        return
    print(fmt_task_row(t))
    print(f"  created: {t['created_ts']}  closed: {t['closed_ts']}  iterations: {t['iterations']}")
    print(f"  final_result: {t['final_result']}  approved_by: {t['approved_by']}")
    print("  verdicts:")
    for v in con.execute("SELECT * FROM verdicts WHERE task_id = ? ORDER BY n", (task_id,)):
        print(f"    #{v['n']} {v['result']} ({v['model']}) {v['ts']}")
    costs = con.execute(
        "SELECT COUNT(*) n, SUM(cost_usd) c FROM trace_events WHERE task_id = ?", (task_id,)
    ).fetchone()
    if costs["n"]:
        print(f"  trace events: {costs['n']}, total cost: ${costs['c'] or 0:.4f}")


def cmd_recent(days):
    con = connect_ro()
    rows = con.execute(
        """SELECT * FROM tasks WHERE created_ts >= datetime('now', ?)
           ORDER BY created_ts DESC""",
        (f"-{days} days",),
    ).fetchall()
    if not rows:
        print(f"no tasks created in the last {days} day(s)")
        return
    for r in rows:
        print(fmt_task_row(r))


def cmd_failures(query):
    con = connect_ro()
    rows = con.execute(
        """SELECT v.task_id, v.n, v.result, v.failed_criteria, t.status, t.title
           FROM verdicts_fts f
           JOIN verdicts v ON v.task_id = f.task_id AND v.n = f.n
           JOIN tasks t ON t.task_id = v.task_id
           WHERE verdicts_fts MATCH ?""",
        (query,),
    ).fetchall()
    if not rows:
        print("no matching failures")
        return
    for r in rows:
        print(f"[{r['status']:>8}] {r['task_id']} verdict#{r['n']} ({r['result']}) {r['title']}")
        for line in r["failed_criteria"].splitlines():
            print(f"    {line}")


def cmd_costs(days):
    con = connect_ro()
    rows = con.execute(
        """SELECT t.task_id, t.status, t.impact_class,
                  COUNT(e.rowid) n_events, SUM(e.cost_usd) total_cost,
                  SUM(e.input_tokens) in_tok, SUM(e.output_tokens) out_tok
           FROM tasks t LEFT JOIN trace_events e ON e.task_id = t.task_id
           WHERE t.created_ts >= datetime('now', ?)
           GROUP BY t.task_id ORDER BY total_cost DESC""",
        (f"-{days} days",),
    ).fetchall()
    if not rows:
        print(f"no tasks in the last {days} day(s)")
        return
    for r in rows:
        cost = r["total_cost"] or 0
        print(f"[{r['status']:>8}] {r['task_id']:35} ${cost:.4f}  in={r['in_tok'] or 0} out={r['out_tok'] or 0}")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    cmd = sys.argv[1]
    arg = sys.argv[2] if len(sys.argv) > 2 else None
    if cmd == "find" and arg:
        cmd_find(arg)
    elif cmd == "grep" and arg:
        cmd_grep(arg)
    elif cmd == "task" and arg:
        cmd_task(arg)
    elif cmd == "recent":
        cmd_recent(int(arg) if arg else 7)
    elif cmd == "failures" and arg:
        cmd_failures(arg)
    elif cmd == "costs":
        cmd_costs(int(arg) if arg else 30)
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main()
