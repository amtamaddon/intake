---
name: run-task
description: The orchestrator loop — build, verify, repeat until PASS or a stop condition, with a mandatory human gate for money/client-facing work. Run this in the main session (the planner), never inside a subagent — the loop's own bookkeeping must live outside the thing it's counting.
---

You (the main session) are the orchestrator for this task. You spawn builder and verifier
subagents; you never build or verify anything yourself, and you never declare a task "done" —
only `scripts/check_done.sh` and, where required, a human do that.

## 0. Gate before spending anything

Run `scripts/check_goal.sh <task-dir>`. If it exits nonzero, stop and report exactly what's
missing. Do not spawn a builder against an incomplete goal.md — this check exists specifically so
an incomplete brief never costs a subagent launch.

Read `goal.md`'s Budget line for the max-iteration cap (default 3 if unspecified) and the
wall-clock cap. Read the Impact class — you'll need it at the end.

## 1. Iterate

For each iteration (starting at 1):

1. Log `scripts/log_append.sh <task-dir> "orchestrator" "ITERATION <n>/<max> START"` — this is
   the loop's own bookkeeping, and it lives in the tamper-evident worklog like everything else.
2. Spawn the `builder` subagent on this task dir. Give it nothing but the task dir path — it reads
   `goal.md`, `plan.md`, `inputs/`, and the latest verdict (if any) itself.
3. Once the builder reports the artifact in `output/` is ready, spawn the `verifier` subagent
   (default model: sonnet, per its frontmatter) with the restricted spawn prompt described in
   `.claude/skills/verify-task/SKILL.md` (step 3) — never paste builder output or your own
   reasoning into that prompt.
4. If the interim (sonnet) verdict is **FAIL**: log
   `scripts/log_append.sh <task-dir> "orchestrator" "VERDICT FAIL iter <n>: <criteria that failed>"`,
   then check the stop conditions below before looping to the next iteration. If the failed
   criteria mention a dollar figure, single-quote the log message — `$184.50` inside double quotes
   is bash parameter expansion and will silently corrupt the amount in the worklog rather than
   error; the verdict file, not the worklog line, is the source of truth for exact figures.
5. If the interim (sonnet) verdict is **PASS**: do not accept it as final. Spawn a second,
   independent `verifier` subagent on the same artifact with an explicit model override to
   **opus** (pass `model: opus` to the Agent tool call — this overrides the frontmatter default).
   Give it the identical restricted spawn prompt; it must not be told the sonnet verifier's
   result. This opus verdict is the one that actually counts and the one `check_done.sh` will read.
   - If opus also says PASS: stop iterating, go to step 3 (closing out).
   - If opus says FAIL where sonnet said PASS: log both verdicts' disagreement, treat this
     iteration as a FAIL, and continue the loop — the cheaper model was wrong, not a reason to
     override the expensive one.
6. If either verifier returns **ESCALATE-TO-HUMAN**: stop the loop immediately and report to the
   user. Do not keep iterating against an inadequate rubric.

## 2. Stop conditions — checked before every new iteration

- **Max iterations**: count `ITERATION n START` entries in the worklog. At the cap from
  `goal.md`'s Budget (default 3): stop, report to the user that the task needs human review rather
  than another automated pass.
- **No progress after N=2**: compare the set of failed criteria between the last two FAIL
  verdicts. If the current failure set is the same as, or a superset of, the previous one: stop —
  more iterations are burning budget, not converging.
- **Budget / wall-clock cap**: compare the current time to the first worklog entry's timestamp
  (`TASK START`, written by `/new-task` or this skill's first run) against the cap in `goal.md`.
  True dollar-cost metering isn't available at this layer; the iteration cap combined with
  CLAUDE.md's model-routing table is the deliberate cost-proxy approximation for the MVP.
- **House-rule trigger**: if the builder or verifier's worklog entries indicate contact with a
  house rule from `goal.md` §3, stop immediately regardless of iteration count and escalate.

Any stop condition firing means: log it, stop iterating, and report to the user. None of these
paths write `APPROVAL.md` or otherwise force the task closed — that remains a human action.

## 3. Closing out

Once an opus PASS verdict exists, run `scripts/check_done.sh <task-dir>`:

- If it exits 0: the task's automated gates are satisfied. If Impact class is `internal`, tell the
  user the task is ready to archive. If Impact class is `money` or `client-facing`,
  `check_done.sh` will already have required `APPROVAL.md` to exist with an `APPROVED` line — if
  it doesn't yet, tell the user precisely that a human sign-off in `<task-dir>/APPROVAL.md` is the
  only remaining step, and stop. Do not create or suggest creating that file's content yourself.
- If it exits nonzero: report the exact failure reason it printed. Do not paper over it.

Never tell the user the task is "done" on the strength of your own judgment — only relay what
`check_done.sh` actually reports.
