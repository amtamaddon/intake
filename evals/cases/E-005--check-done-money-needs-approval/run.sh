#!/usr/bin/env bash
# E-005: check_done.sh must refuse a money/client-facing task without a valid
# APPROVAL.md, and accept it once one exists with an APPROVED line.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts" && pwd)"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/verdicts"

cat > "$tmp/goal.md" <<'EOF'
# GOAL: eval fixture

- **Task ID:** eval--fixture
- **Impact class:** money
- **Budget:** 3 iterations

## 1. End State
A file exists.

## 2. Verification Method
Check the file exists.

## 3. House Rules — things that must NEVER happen
Never do the bad thing.

## 4. Stop Conditions
Stop after 3 tries.
EOF

cat > "$tmp/verdicts/verdict-001.md" <<'EOF'
# VERDICT 001 — eval--fixture
- Result: PASS
- Verifier model: opus, fresh context: yes
- Timestamp: 2026-01-01T00:00:00Z
EOF

if bash "$script_dir/check_done.sh" "$tmp" >/dev/null 2>&1; then
  echo "E-005 FAIL: check_done.sh passed a money-class task with no APPROVAL.md"
  exit 1
fi

echo "APPROVED - Eval Tester - 2026-01-01T00:00:00Z" > "$tmp/APPROVAL.md"

bash "$script_dir/check_done.sh" "$tmp" >/dev/null || { echo "E-005 FAIL: check_done.sh rejected a task with a valid PASS verdict and a real APPROVAL.md"; exit 1; }
echo "E-005 OK"
