---
name: verify-task
description: Spawn a standalone verifier pass on a task's current output/, outside the normal run-task loop. Use for a manual re-check without triggering another builder iteration.
---

Given a task dir:

1. Confirm `output/` is non-empty and `rubric.md` has no remaining `FILL-ME`. If either fails, say
   so and stop — there is nothing to verify yet.
2. Determine the next verdict number: count existing `verdicts/verdict-*.md`, zero-pad to 3 digits
   (`001`, `002`, ...).
3. Spawn the `verifier` subagent (Agent tool, `subagent_type: verifier`) with a spawn prompt
   restricted to exactly: *"Verify task `<task-dir>` per `.claude/agents/verifier.md`. Next verdict
   number is `<NNN>`. Read only the files listed there."* Do not paste any of the current
   conversation, builder reasoning, or your own opinion of the artifact into that prompt — the
   verifier's context must be limited to what its own definition tells it to read.
4. Report the verdict result to the user once the subagent returns. Do not act on FAIL yourself —
   this skill does not loop or re-spawn a builder; that's `/run-task`'s job.

This is a manual check, not part of the enforced loop — it does not consume an iteration from
`goal.md`'s Budget and does not by itself satisfy `check_done.sh` unless its result happens to be
the latest verdict when `check_done.sh` runs.
