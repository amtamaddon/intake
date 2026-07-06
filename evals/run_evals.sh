#!/usr/bin/env bash
# The evals gate. Deterministic tier runs always (this is what the pre-commit hook
# calls); the LLM-judge tier is opt-in (--llm) since it spends real tokens and time.
# Usage: evals/run_evals.sh [--llm] [--case E-NNN]
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

llm=0
only=""
while [ $# -gt 0 ]; do
  case "$1" in
    --llm) llm=1 ;;
    --case) shift; only="${1:-}" ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
  shift
done

pass=0
fail=0
failed_ids=""

for c in evals/cases/E-0*/; do
  id=$(basename "$c")
  [ -n "$only" ] && [ "$id" != "$only" ] && continue
  log=$(mktemp)
  if (cd "$c" && bash run.sh) > "$log" 2>&1; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    failed_ids="$failed_ids $id"
    echo "--- $id FAILED ---"
    cat "$log"
  fi
  rm -f "$log"
done

if [ "$llm" -eq 1 ]; then
  for c in evals/cases/E-1*/; do
    id=$(basename "$c")
    [ -n "$only" ] && [ "$id" != "$only" ] && continue
    [ -f "$c/case.md" ] || continue
    tmp=$(mktemp -d)
    cp -r "$c/fixture-task" "$tmp/fixture-task"
    if (cd "$tmp" && claude -p "$(cat "$repo_root/$c/case.md")" --permission-mode acceptEdits) > "$tmp/session.log" 2>&1 \
       && bash "$repo_root/$c/assert.sh" "$tmp/fixture-task" > "$tmp/assert.log" 2>&1; then
      pass=$((pass + 1))
      cat "$tmp/assert.log"
    else
      fail=$((fail + 1))
      failed_ids="$failed_ids $id"
      echo "--- $id FAILED ---"
      cat "$tmp/session.log" "$tmp/assert.log" 2>/dev/null
    fi
    rm -rf "$tmp"
  done
fi

git_rev=$(git rev-parse --short HEAD 2>/dev/null || echo "no-commit")
printf '{"ts":"%s","git":"%s","pass":%d,"fail":%d,"failed":"%s","llm":%s}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$git_rev" "$pass" "$fail" "${failed_ids# }" "$([ $llm -eq 1 ] && echo true || echo false)" \
  >> evals/results/results.jsonl

echo
echo "evals: $pass passed, $fail failed$([ $llm -eq 1 ] && echo ' (llm tier included)' || echo ' (deterministic tier only, use --llm for the judge tier)')"
[ "$fail" -eq 0 ]
