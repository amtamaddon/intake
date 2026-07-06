#!/usr/bin/env python3
"""Index one task directory into memory/episodes.db. Idempotent: full delete +
reinsert for this task_id. Refuses to index a task whose hash chain doesn't
verify -- the DB must never contain data the worklog chain doesn't vouch for.

Usage: index_task.py <task-dir>
"""
import re
import sqlite3
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

REPO_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = REPO_ROOT / "memory" / "episodes.db"
SCHEMA_PATH = REPO_ROOT / "memory" / "schema.sql"


def ensure_schema(con):
    con.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))


def verify_worklog(task_dir: Path) -> bool:
    verify_script = REPO_ROOT / "scripts" / "verify_worklog.sh"
    result = subprocess.run(
        ["bash", str(verify_script), str(task_dir)],
        capture_output=True, text=True,
    )
    return result.returncode == 0


def parse_worklog(task_dir: Path):
    path = task_dir / "worklog.md"
    if not path.exists():
        return []
    lines = path.read_text(encoding="utf-8").splitlines()
    entries = []
    i = 0
    n = len(lines)
    while i < n:
        if lines[i].strip() == "---":
            header = {}
            i += 1
            while i < n and lines[i].strip() != "---":
                if ":" in lines[i]:
                    k, v = lines[i].split(":", 1)
                    header[k.strip()] = v.strip()
                i += 1
            i += 1  # skip closing '---'
            msg_lines = []
            while i < n and lines[i].strip() != "---":
                if lines[i].strip() != "":
                    msg_lines.append(lines[i])
                i += 1
            entries.append({
                "seq": int(header.get("seq", 0)),
                "ts": header.get("ts", ""),
                "actor": header.get("actor", ""),
                "prev": header.get("prev", ""),
                "hash": header.get("hash", ""),
                "message": "\n".join(msg_lines),
            })
        else:
            i += 1
    return entries


def parse_goal(task_dir: Path):
    path = task_dir / "goal.md"
    text = path.read_text(encoding="utf-8") if path.exists() else ""
    title_match = re.search(r"^#\s*GOAL:\s*(.+)$", text, re.MULTILINE)
    title = title_match.group(1).strip() if title_match else task_dir.name

    impact_match = re.search(r"^-\s*\*\*Impact class:\*\*\s*(.+)$", text, re.MULTILINE)
    impact = "internal"
    if impact_match:
        raw = impact_match.group(1)
        raw = re.sub(r"<!--.*", "", raw).strip()
        token = raw.split()[0] if raw.split() else "internal"
        if token in ("internal", "money", "client-facing"):
            impact = token

    tags_match = re.search(r"^-\s*\*\*Tags:\*\*\s*(.+)$", text, re.MULTILINE)
    tags = tags_match.group(1).strip() if tags_match else ""

    return title, impact, tags, text


def parse_verdicts(task_dir: Path):
    verdicts_dir = task_dir / "verdicts"
    out = []
    if not verdicts_dir.exists():
        return out
    for p in sorted(verdicts_dir.glob("verdict-*.md")):
        text = p.read_text(encoding="utf-8")
        m = re.search(r"^\s*-\s*Result:\s*(PASS|FAIL|ESCALATE-TO-HUMAN)\s*$", text, re.MULTILINE)
        result = m.group(1) if m else None
        model_m = re.search(r"^\s*-\s*Verifier model:\s*([^,]+)", text, re.MULTILINE)
        model = model_m.group(1).strip() if model_m else None
        ts_m = re.search(r"^\s*-\s*Timestamp:\s*(.+)$", text, re.MULTILINE)
        ts = ts_m.group(1).strip() if ts_m else None
        fail_rows = [l for l in text.splitlines() if "| FAIL" in l or "FAIL |" in l]
        n_match = re.search(r"(\d+)", p.stem)
        n = int(n_match.group(1)) if n_match else 0
        if result:
            out.append({
                "n": n, "result": result, "model": model, "ts": ts,
                "failed_criteria": "\n".join(fail_rows), "path": str(p.relative_to(REPO_ROOT)),
            })
    return out


def parse_approval(task_dir: Path):
    path = task_dir / "APPROVAL.md"
    if not path.exists():
        return None
    m = re.search(r"^APPROVED\s*-\s*(.+?)\s*-\s*(.+)$", path.read_text(encoding="utf-8"), re.MULTILINE)
    return m.group(1).strip() if m else None


def index_task(task_dir: Path):
    task_dir = task_dir.resolve()
    task_id = task_dir.name

    if not (task_dir / "goal.md").exists():
        print(f"index_task: skip {task_id} -- no goal.md")
        return False

    if (task_dir / "worklog.md").exists():
        if not verify_worklog(task_dir):
            print(f"index_task: REFUSED -- {task_id}'s worklog chain does not verify; will not index unverifiable history")
            return False

    entries = parse_worklog(task_dir)
    title, impact, tags, goal_text = parse_goal(task_dir)
    verdicts = parse_verdicts(task_dir)
    approved_by = parse_approval(task_dir)

    iterations = sum(1 for e in entries if re.match(r"ITERATION \d+/\d+ START", e["message"]))
    created_ts = entries[0]["ts"] if entries else None
    final_result = verdicts[-1]["result"] if verdicts else None

    is_archived = "archive" in task_dir.parts
    if final_result == "PASS" and (impact == "internal" or approved_by):
        status = "archived" if is_archived else "done"
    elif is_archived:
        status = "archived"
    else:
        status = "active"

    closed_ts = entries[-1]["ts"] if (status in ("done", "archived") and entries) else None

    head_file = task_dir / ".worklog_head"
    worklog_tip_hash = head_file.read_text(encoding="utf-8").strip() if head_file.exists() else None

    con = sqlite3.connect(DB_PATH)
    try:
        ensure_schema(con)
        cur = con.cursor()
        cur.execute("DELETE FROM tasks_fts WHERE task_id = ?", (task_id,))
        cur.execute("DELETE FROM worklog_fts WHERE task_id = ?", (task_id,))
        cur.execute("DELETE FROM verdicts_fts WHERE task_id = ?", (task_id,))
        cur.execute("DELETE FROM tasks WHERE task_id = ?", (task_id,))  # cascades

        cur.execute(
            """INSERT INTO tasks (task_id, title, impact_class, status, created_ts, closed_ts,
               iterations, final_result, approved_by, goal_text, tags, worklog_tip_hash, indexed_ts)
               VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)""",
            (task_id, title, impact, status, created_ts, closed_ts, iterations, final_result,
             approved_by, goal_text, tags, worklog_tip_hash,
             datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")),
        )
        cur.execute("INSERT INTO tasks_fts (title, goal_text, tags, task_id) VALUES (?,?,?,?)",
                    (title, goal_text, tags, task_id))

        for e in entries:
            cur.execute(
                """INSERT INTO worklog_entries (task_id, seq, ts, actor, prev, hash, message)
                   VALUES (?,?,?,?,?,?,?)""",
                (task_id, e["seq"], e["ts"], e["actor"], e["prev"], e["hash"], e["message"]),
            )
            cur.execute("INSERT INTO worklog_fts (message, actor, task_id, seq) VALUES (?,?,?,?)",
                        (e["message"], e["actor"], task_id, e["seq"]))

        for v in verdicts:
            cur.execute(
                """INSERT INTO verdicts (task_id, n, result, model, ts, failed_criteria, path)
                   VALUES (?,?,?,?,?,?,?)""",
                (task_id, v["n"], v["result"], v["model"], v["ts"], v["failed_criteria"], v["path"]),
            )
            cur.execute("INSERT INTO verdicts_fts (failed_criteria, task_id, n) VALUES (?,?,?)",
                        (v["failed_criteria"], task_id, v["n"]))

        con.commit()
    finally:
        con.close()

    print(f"index_task: OK -- {task_id} ({len(entries)} worklog entries, {len(verdicts)} verdicts, status={status})")
    return True


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: index_task.py <task-dir>", file=sys.stderr)
        sys.exit(2)
    ok = index_task(Path(sys.argv[1]))
    sys.exit(0 if ok else 1)
