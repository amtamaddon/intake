#!/usr/bin/env bash
# E-009: trace_append.py must compute cost_usd correctly from pricing.tsv, and
# trace_report.py must roll it up correctly. Uses sonnet's known rate: $3/mtok in,
# $15/mtok out, $0.30/mtok cache-read.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts" && pwd)"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

python "$script_dir/trace_append.py" "$tmp" subagent --actor builder --model sonnet \
  --iteration 1 --latency 12.5 --input-tokens 5000 --output-tokens 800 --cache-read-tokens 2000 \
  --outcome "test" >/dev/null

python - "$tmp" <<'PYEOF'
import json, sys
tmp = sys.argv[1]
with open(f"{tmp}/trace.jsonl") as f:
    event = json.loads(f.readline())
expected = round((5000/1_000_000)*3.00 + (800/1_000_000)*15.00 + (2000/1_000_000)*0.30, 6)
actual = event.get("cost_usd")
assert actual == expected, f"E-009 FAIL: expected cost {expected}, got {actual}"
print(f"E-009: cost computed correctly ({actual})")
PYEOF

out=$(python "$script_dir/trace_report.py" "$tmp")
echo "$out" | grep -q '0.0276' || { echo "E-009 FAIL: trace_report.py did not roll up the expected total: $out"; exit 1; }

echo "E-009 OK"
