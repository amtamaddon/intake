#!/usr/bin/env bash
# The only sanctioned way to write worklog entries.
# Append-only, hash-chained: each entry's hash covers seq+ts+actor+prev+message
# (joined by \x1f so message content can't collide with the delimiter), and each
# new entry's prev must equal the previous entry's hash. Only sha256sum + this
# script ever touch worklog.md — see .claude/settings.json for the deny rules
# that make that true.
# Usage: log_append.sh <task-dir> <actor> <message...>
set -euo pipefail

task_dir="${1:?usage: log_append.sh <task-dir> <actor> <message>}"
actor="${2:?usage: log_append.sh <task-dir> <actor> <message>}"
shift 2
message="$*"
[ -n "${message:-}" ] || { echo "log_append: message required" >&2; exit 1; }
case "$message" in
  *$'\n'*) echo "log_append: message must be a single line — no embedded newlines" >&2; exit 1 ;;
esac

worklog="$task_dir/worklog.md"
head_file="$task_dir/.worklog_head"
touch "$worklog"

seq=$(( $(grep -c '^seq: ' "$worklog" 2>/dev/null || true) + 1 ))
prev="GENESIS"
[ -f "$head_file" ] && prev="$(cat "$head_file")"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
hash=$(printf '%s\x1f%s\x1f%s\x1f%s\x1f%s' "$seq" "$ts" "$actor" "$prev" "$message" | sha256sum | cut -c1-12)

{
  echo "---"
  echo "seq: $seq"
  echo "ts: $ts"
  echo "actor: $actor"
  echo "prev: $prev"
  echo "hash: $hash"
  echo "---"
  echo "$message"
  echo
} >> "$worklog"

printf '%s' "$hash" > "$head_file"
echo "log_append: entry $seq appended (hash $hash)"
