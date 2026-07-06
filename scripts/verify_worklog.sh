#!/usr/bin/env bash
# Recomputes the worklog hash chain; nonzero exit on any break.
# Parses each --- header --- message block, recomputes its hash from the
# recorded fields, and checks (a) the recomputed hash matches the declared
# 'hash:' field (tamper check) and (b) each entry's 'prev:' matches the
# previous entry's declared hash (chain-linkage check).
# Usage: verify_worklog.sh <task-dir>
set -euo pipefail
task_dir="${1:?usage: verify_worklog.sh <task-dir>}"
worklog="$task_dir/worklog.md"
[ -f "$worklog" ] || { echo "verify_worklog: no worklog.md — nothing to verify"; exit 0; }

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

awk -v out="$tmp_dir" '
  BEGIN{n=0; state=0}
  /^---$/{
    state++
    if (state % 2 == 1) { n++; next }   # opening delimiter of a new entry
    else { next }                        # closing delimiter
  }
  {
    if (state == 0) next
    if (state % 2 == 1) { print $0 >> (out "/h" n); next }   # inside header
    if ($0 != "") print $0 >> (out "/m" n)                    # inside message, skip blank separator lines
  }
  END{ print n > (out "/count") }
' "$worklog"

count=$(cat "$tmp_dir/count" 2>/dev/null || echo 0)
[ "$count" -gt 0 ] || { echo "verify_worklog: no entries parsed"; exit 1; }

expected_prev="GENESIS"
broken=0
for i in $(seq 1 "$count"); do
  h="$tmp_dir/h$i"; m="$tmp_dir/m$i"
  [ -f "$h" ] || h=/dev/null
  [ -f "$m" ] || m=/dev/null
  seq_n=$(grep -m1 '^seq: ' "$h" | sed 's/^seq: //')
  ts=$(grep -m1 '^ts: ' "$h" | sed 's/^ts: //')
  actor=$(grep -m1 '^actor: ' "$h" | sed 's/^actor: //')
  prev=$(grep -m1 '^prev: ' "$h" | sed 's/^prev: //')
  declared_hash=$(grep -m1 '^hash: ' "$h" | sed 's/^hash: //')
  message=$(cat "$m")

  if [ "$prev" != "$expected_prev" ]; then
    echo "verify_worklog: BROKEN CHAIN at entry $seq_n — expected prev '$expected_prev', found '$prev'"
    broken=1
  fi
  recomputed=$(printf '%s\x1f%s\x1f%s\x1f%s\x1f%s' "$seq_n" "$ts" "$actor" "$prev" "$message" | sha256sum | cut -c1-12)
  if [ "$recomputed" != "$declared_hash" ]; then
    echo "verify_worklog: TAMPERED entry $seq_n — recomputed hash '$recomputed' != declared '$declared_hash'"
    broken=1
  fi
  expected_prev="$declared_hash"
done

head_file="$task_dir/.worklog_head"
if [ -f "$head_file" ]; then
  recorded_tip="$(cat "$head_file")"
  if [ "$recorded_tip" != "$expected_prev" ]; then
    echo "verify_worklog: TRUNCATED — .worklog_head says tip is '$recorded_tip' but the file ends at '$expected_prev'"
    broken=1
  fi
fi

if [ "$broken" -ne 0 ]; then
  echo "verify_worklog: FAIL — chain integrity broken"
  exit 1
fi
echo "verify_worklog: OK — $count entries, chain intact"
