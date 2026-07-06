#!/usr/bin/env python3
"""Drop and fully rebuild memory/episodes.db from the flat files under tasks/ and
archive/tasks/. Proves the DB is genuinely derived: this should produce an
equivalent index to whatever incremental indexing already did.
"""
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = REPO_ROOT / "memory" / "episodes.db"

sys.path.insert(0, str(Path(__file__).resolve().parent))
from index_task import index_task  # noqa: E402


def main():
    for suffix in ("", "-wal", "-shm"):
        p = Path(str(DB_PATH) + suffix)
        if p.exists():
            p.unlink()

    indexed = 0
    skipped = 0
    for base in (REPO_ROOT / "tasks", REPO_ROOT / "archive" / "tasks"):
        if not base.exists():
            continue
        for task_dir in sorted(base.iterdir()):
            if not task_dir.is_dir():
                continue
            if (task_dir / "goal.md").exists():
                if index_task(task_dir):
                    indexed += 1
                else:
                    skipped += 1

    print(f"index_rebuild: done -- {indexed} indexed, {skipped} skipped")


if __name__ == "__main__":
    main()
