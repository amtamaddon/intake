#!/usr/bin/env bash
# E-003: deleting the LAST worklog entry (leaving .worklog_head stale, pointing to
# a hash no longer present) must be caught by verify_worklog.sh as a truncation.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
fixture="$repo_root/archive/tasks/2026-07-06--dry-run"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$fixture/worklog.md" "$tmp/worklog.md"
[ -f "$fixture/.worklog_head" ] && cp "$fixture/.worklog_head" "$tmp/.worklog_head"

bash "$script_dir/verify_worklog.sh" "$tmp" >/dev/null || { echo "E-003 FAIL: fixture chain was already broken before truncation"; exit 1; }

# Entry 9 is the 17th/18th occurrence of the '---' delimiter (9 entries x 2 each).
# Cut everything from its opening delimiter onward, leaving .worklog_head stale.
delim_line=$(grep -n '^---$' "$tmp/worklog.md" | sed -n '17p' | cut -d: -f1)
[ -n "$delim_line" ] || { echo "E-003 FAIL: could not locate entry 9's delimiter in fixture"; exit 1; }
head -n "$((delim_line - 1))" "$tmp/worklog.md" > "$tmp/worklog.md.new"
mv "$tmp/worklog.md.new" "$tmp/worklog.md"

output=$(bash "$script_dir/verify_worklog.sh" "$tmp" 2>&1) && rc=0 || rc=$?
if [ "$rc" -eq 0 ]; then
  echo "E-003 FAIL: verify_worklog.sh did not detect truncation (exited 0)"
  exit 1
fi
echo "$output" | grep -qi 'TRUNCATED' || { echo "E-003 FAIL: nonzero exit but no TRUNCATED message: $output"; exit 1; }
echo "E-003 OK"
