# STATE — read at session start, updated only via /close-session

Last updated: 2026-07-06 | Line count: 23/200

## 1. Verified Facts
- The full build->verify->fail->iterate->pass->close-session loop works end to end against real
  subagents (not simulated) — 2026-07-06--dry-run — 2026-07-06.
- Custom `.claude/agents/*.md` are only discoverable when Claude Code's session root IS this
  harness directory — a session rooted at a parent directory cannot spawn `builder`/`verifier`/
  `extractor` by name — 2026-07-06.

## 2. General Rules
(none yet — this section holds standing rules that emerged from task experience;
the baseline house rules that apply from day one live in CLAUDE.md)

## 3. Open Failures
- Verifier's tool restriction (no Write/Edit) does not stop it from *reading* worklog.md/plan.md
  via Bash — only a prompt-level instruction currently prevents this. One observed near-miss
  (2026-07-06--dry-run, iteration-2 interim verifier read worklog.md post-verdict, self-disclosed,
  did not affect grading). Not yet hardened with a PreToolUse hook per the don't-overengineer rule
  — revisit if a second, non-benign occurrence happens. — status: open, low severity.

## 4. Lessons Learned
(none yet at confirmed status — two real candidates are being tracked in skills/_INDEX.md with
one confirmation each; see there)

## 5. Last Session Summary
Built and dry-ran the full harness (scaffolding, scripts, agents, skills) 2026-07-06. Fable's
plan review caught two blockers (log_append.sh arithmetic bug, check_done.sh PASS-anchor bug) and
several high/medium issues, all fixed and re-tested. Ran a synthetic internal-class task
(2026-07-06--dry-run) through real subagents end to end: FAIL -> fix -> sonnet PASS -> opus PASS
-> check_done OK. Surfaced two real lessons (dollar-sign log mangling; verifier worklog-read gap)
now tracked as single-confirmation candidates. Confirmed custom agents require the harness dir as
session root, not a parent dir. Next: run from a session actually rooted here, then collect the
four real specifics for the client-intake-processing task (fields, source docs, escalation
target, PII rule) and run it for real.
