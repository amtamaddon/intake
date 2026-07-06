#!/usr/bin/env bash
# E-001: dollar amounts in log_append.sh messages must survive intact when the
# caller single-quotes them (the sanctioned form). Also documents the historical
# trap (L-1): an unquoted/double-quoted $ in the CALLING shell expands before
# log_append.sh ever sees the string. If this trap stops reproducing, the script's
# quoting behavior changed -- update or retire this half of the eval, don't delete it silently.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts" && pwd)"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# --- Safe path ---
bash "$script_dir/log_append.sh" "$tmp" "tester" 'Amount corrected to $184.50 per memo'
grep -qF '$184.50' "$tmp/worklog.md" || { echo "E-001 FAIL: safe (single-quoted) path did not preserve \$184.50"; exit 1; }
bash "$script_dir/verify_worklog.sh" "$tmp" >/dev/null || { echo "E-001 FAIL: chain broken on safe path"; exit 1; }

# --- Trap path (documents the danger; does not assert the script prevents it) ---
tmp2=$(mktemp -d)
trap 'rm -rf "$tmp2"' EXIT
cmd_string="\"$script_dir/log_append.sh\" \"$tmp2\" tester \"Amount is \$184.50\""
bash -c "$cmd_string" || true
if [ -f "$tmp2/worklog.md" ] && grep -qF '$184.50' "$tmp2/worklog.md"; then
  echo "E-001 NOTE: the historical trap no longer corrupts unquoted \$ amounts -- log_append.sh's calling convention may have changed. Review before treating this as a regression."
fi
rm -rf "$tmp2"

echo "E-001 OK"
