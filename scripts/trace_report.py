#!/usr/bin/env python3
"""Per-task trace rollup: totals by actor and by iteration, read straight from
trace.jsonl. Works standalone, without the episodic DB.

Usage: trace_report.py <task-dir>
"""
import json
import sys
from collections import defaultdict
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def main():
    if len(sys.argv) != 2:
        print("usage: trace_report.py <task-dir>", file=sys.stderr)
        sys.exit(2)

    task_dir = Path(sys.argv[1])
    trace_path = task_dir / "trace.jsonl"
    if not trace_path.exists():
        print(f"trace_report: no trace.jsonl at {trace_path}")
        return

    events = []
    with open(trace_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                events.append(json.loads(line))

    by_actor = defaultdict(lambda: {"n": 0, "cost": 0.0, "in": 0, "out": 0, "latency": 0.0})
    by_iter = defaultdict(lambda: {"n": 0, "cost": 0.0})
    total_cost = 0.0

    for e in events:
        actor = e.get("actor", "?")
        a = by_actor[actor]
        a["n"] += 1
        a["cost"] += e.get("cost_usd", 0) or 0
        a["in"] += e.get("input_tokens", 0) or 0
        a["out"] += e.get("output_tokens", 0) or 0
        a["latency"] += e.get("latency_s", 0) or 0
        total_cost += e.get("cost_usd", 0) or 0

        it = e.get("iteration")
        if it is not None:
            by_iter[it]["n"] += 1
            by_iter[it]["cost"] += e.get("cost_usd", 0) or 0

    print(f"=== {task_dir.name}: {len(events)} trace events, ${total_cost:.4f} total ===")
    print("\nBy actor:")
    for actor, s in sorted(by_actor.items()):
        print(f"  {actor:20} n={s['n']:3} cost=${s['cost']:.4f} in={s['in']} out={s['out']} latency={s['latency']:.1f}s")
    if by_iter:
        print("\nBy iteration:")
        for it, s in sorted(by_iter.items()):
            print(f"  iteration {it}: n={s['n']} cost=${s['cost']:.4f}")


if __name__ == "__main__":
    main()
