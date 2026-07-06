#!/usr/bin/env bash
# E-004: check_goal.sh must refuse an incomplete goal.md (FILL-ME sentinel present,
# or an invalid Impact class), and accept a properly filled one.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts" && pwd)"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/goal.md" <<'EOF'
# GOAL: eval fixture

- **Task ID:** eval--fixture
- **Impact class:** FILL-ME
- **Budget:** 3 iterations

## 1. End State
FILL-ME

## 2. Verification Method
FILL-ME

## 3. House Rules — things that must NEVER happen
FILL-ME

## 4. Stop Conditions
FILL-ME
EOF

if bash "$script_dir/check_goal.sh" "$tmp" >/dev/null 2>&1; then
  echo "E-004 FAIL: check_goal.sh accepted a goal.md full of FILL-ME sentinels"
  exit 1
fi

cat > "$tmp/goal.md" <<'EOF'
# GOAL: eval fixture

- **Task ID:** eval--fixture
- **Impact class:** internal
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

bash "$script_dir/check_goal.sh" "$tmp" >/dev/null || { echo "E-004 FAIL: check_goal.sh rejected a fully filled goal.md"; exit 1; }
echo "E-004 OK"
