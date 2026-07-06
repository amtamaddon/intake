#!/usr/bin/env bash
# E-002: editing a past worklog entry's message must be caught by verify_worklog.sh.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
fixture="$repo_root/archive/tasks/2026-07-06--dry-run"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$fixture/worklog.md" "$tmp/worklog.md"
[ -f "$fixture/.worklog_head" ] && cp "$fixture/.worklog_head" "$tmp/.worklog_head"

bash "$script_dir/verify_worklog.sh" "$tmp" >/dev/null || { echo "E-002 FAIL: fixture chain was already broken before tampering"; exit 1; }

sed -i 's/ITERATION 1\/3 START/TAMPERED MESSAGE/' "$tmp/worklog.md"

if bash "$script_dir/verify_worklog.sh" "$tmp" >/dev/null 2>&1; then
  echo "E-002 FAIL: verify_worklog.sh did not detect a tampered entry"
  exit 1
fi
echo "E-002 OK"
