#!/usr/bin/env python3
"""The only sanctioned way to append to a task's trace.jsonl. Computes cost_usd
from token counts x scripts/pricing.tsv when both are present, stamps ts, appends
one validated JSON line. Direct Write/Edit on trace.jsonl is permission-denied;
this script is the door.

Usage: trace_append.py <task-dir> <event> [--actor A] [--model M] [--iteration N]
       [--latency S] [--input-tokens N] [--output-tokens N]
       [--cache-read-tokens N] [--cache-write-tokens N] [--outcome TEXT]
"""
import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PRICING_PATH = REPO_ROOT / "scripts" / "pricing.tsv"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def load_pricing():
    rows = {}
    with open(PRICING_PATH, encoding="utf-8") as f:
        header = f.readline()
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) != 4:
                continue
            model, mtok_in, mtok_out, mtok_cache = parts
            rows[model] = (float(mtok_in), float(mtok_out), float(mtok_cache))
    return rows


def compute_cost(model, in_tok, out_tok, cache_read_tok):
    pricing = load_pricing()
    if model not in pricing or in_tok is None or out_tok is None:
        return None
    p_in, p_out, p_cache = pricing[model]
    cost = (in_tok / 1_000_000) * p_in + (out_tok / 1_000_000) * p_out
    if cache_read_tok:
        cost += (cache_read_tok / 1_000_000) * p_cache
    return round(cost, 6)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("task_dir")
    ap.add_argument("event")
    ap.add_argument("--actor")
    ap.add_argument("--model")
    ap.add_argument("--iteration", type=int)
    ap.add_argument("--latency", type=float)
    ap.add_argument("--input-tokens", type=int)
    ap.add_argument("--output-tokens", type=int)
    ap.add_argument("--cache-read-tokens", type=int)
    ap.add_argument("--cache-write-tokens", type=int)
    ap.add_argument("--outcome")
    args = ap.parse_args()

    task_dir = Path(args.task_dir)
    if not task_dir.exists():
        print(f"trace_append: no such task dir: {task_dir}", file=sys.stderr)
        sys.exit(1)

    event = {
        "ts": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "event": args.event,
    }
    if args.actor:
        event["actor"] = args.actor
    if args.model:
        event["model"] = args.model
    if args.iteration is not None:
        event["iteration"] = args.iteration
    if args.latency is not None:
        event["latency_s"] = args.latency
    if args.input_tokens is not None:
        event["input_tokens"] = args.input_tokens
    if args.output_tokens is not None:
        event["output_tokens"] = args.output_tokens
    if args.cache_read_tokens is not None:
        event["cache_read_tokens"] = args.cache_read_tokens
    if args.cache_write_tokens is not None:
        event["cache_write_tokens"] = args.cache_write_tokens
    if args.outcome:
        event["outcome"] = args.outcome

    cost = compute_cost(args.model, args.input_tokens, args.output_tokens, args.cache_read_tokens)
    if cost is not None:
        event["cost_usd"] = cost

    line = json.dumps(event, ensure_ascii=False)
    trace_path = task_dir / "trace.jsonl"
    with open(trace_path, "a", encoding="utf-8") as f:
        f.write(line + "\n")

    print(f"trace_append: OK -- {args.event}" + (f" cost=${cost:.6f}" if cost is not None else ""))


if __name__ == "__main__":
    main()
