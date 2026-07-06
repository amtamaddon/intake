#!/usr/bin/env bash
# E-006: lints the load-bearing strings a well-meaning edit could silently break.
# This is the enforceable half of the L-2 finding (verifier can technically read
# worklog.md/plan.md via Bash) -- it can't stop that at the tool level, but it
# guards the prompt-level and permission-level guarantees from silent regression.
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
fail=0
check() { if ! eval "$2"; then echo "E-006 FAIL: $1"; fail=1; fi; }

settings="$repo_root/.claude/settings.json"
check "settings.json denies Write on APPROVAL.md" "grep -q 'Write(\*\*/APPROVAL.md)' '$settings'"
check "settings.json denies Edit on APPROVAL.md"  "grep -q 'Edit(\*\*/APPROVAL.md)' '$settings'"
check "settings.json denies Write on worklog.md"  "grep -q 'Write(\*\*/worklog.md)' '$settings'"
check "settings.json denies Edit on worklog.md"   "grep -q 'Edit(\*\*/worklog.md)' '$settings'"
check "settings.json denies Write on MEMORY.md"   "grep -q 'Write(MEMORY.md)' '$settings'"
check "settings.json denies Edit on MEMORY.md"    "grep -q 'Edit(MEMORY.md)' '$settings'"
check "settings.json denies Write on trace.jsonl" "grep -q 'Write(\*\*/trace.jsonl)' '$settings'"
check "settings.json denies Edit on trace.jsonl"  "grep -q 'Edit(\*\*/trace.jsonl)' '$settings'"

verifier="$repo_root/.claude/agents/verifier.md"
check "verifier.md tools line excludes Write" "! grep -m1 '^tools:' '$verifier' | grep -qw Write"
check "verifier.md tools line excludes Edit"  "! grep -m1 '^tools:' '$verifier' | grep -qw Edit"
check "verifier.md still forbids reading worklog.md" "grep -q 'worklog.md' '$verifier'"
check "verifier.md still forbids reading plan.md"    "grep -q 'plan.md' '$verifier'"

builder="$repo_root/.claude/agents/builder.md"
check "builder.md still forbids writing to verdicts/" "grep -qi 'verdicts/' '$builder'"
check "builder.md still forbids writing APPROVAL.md"  "grep -q 'APPROVAL.md' '$builder'"

done_script="$repo_root/scripts/check_done.sh"
check "check_done.sh still anchors the PASS match" "grep -qE '\\^- Result: PASS\\[\\[:space:\\]\\]\\*\\\$' '$done_script'"

[ "$fail" -eq 0 ] && echo "E-006 OK" || exit 1
