#!/usr/bin/env bash
# E-008: find_procedure.sh's --code matching must not crash (regression for a real
# bug: grep -i combined with -F core-dumps on this machine's GNU grep 3.0), and its
# draft/active filtering must behave as designed.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
proc_dir="$repo_root/procedures/__eval_fixture__"

mkdir -p "$proc_dir"
trap 'rm -rf "$proc_dir"' EXIT

cat > "$proc_dir/draft.md" <<'EOF'
---
id: PROC-EVALTEST1
title: Eval fixture draft procedure
payer: evalpayer
category: denial-resubmission
codes: [CO-999]
version: 1
status: draft
approved_by:
---
## When this applies
fixture
EOF

cat > "$proc_dir/active.md" <<'EOF'
---
id: PROC-EVALTEST2
title: Eval fixture active procedure
payer: evalpayer
category: denial-resubmission
codes: [CO-197]
version: 2
status: active
approved_by: Eval Tester, 2026-01-01
---
## When this applies
fixture
EOF

out=$(bash "$script_dir/find_procedure.sh" --code CO-197 2>&1) || { echo "E-008 FAIL: crashed or errored on --code lookup: $out"; exit 1; }
echo "$out" | grep -q 'PROC-EVALTEST2' || { echo "E-008 FAIL: did not find the active procedure by code: $out"; exit 1; }

out=$(bash "$script_dir/find_procedure.sh" --code CO-999 2>&1) && rc=0 || rc=$?
[ "$rc" -eq 3 ] || { echo "E-008 FAIL: expected exit 3 (no matches) for a draft-only code, got $rc: $out"; exit 1; }

out=$(bash "$script_dir/find_procedure.sh" --code CO-999 --include-draft 2>&1) || { echo "E-008 FAIL: --include-draft lookup failed: $out"; exit 1; }
echo "$out" | grep -q 'PROC-EVALTEST1' || { echo "E-008 FAIL: --include-draft did not surface the draft procedure: $out"; exit 1; }

echo "E-008 OK"
