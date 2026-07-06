# Admin-Services Harness

An agentic harness for admin-services automation. See `CLAUDE.md` for the full constitution
(roles, model routing, house rules, session protocol).

## Running a task

1. `/new-task <slug>` — scaffolds `tasks/<date>--<slug>/` from the templates. Fill in every
   `FILL-ME` in the resulting `goal.md` and write `rubric.md` before starting.
2. `/run-task <slug>` — runs the build → verify loop until PASS, a stop condition, or a
   house-rule trigger. Refuses to start if `goal.md` is incomplete (`scripts/check_goal.sh`).
3. If the task's Impact class is `money` or `client-facing`, a human must create `APPROVAL.md`
   in the task folder with an `APPROVED` line before the task can close — no agent can write
   that file (see `.claude/settings.json`).
4. `/close-session` at the end of every session — updates `STATE.md`, prunes it, tallies lesson
   confirmations.

## Low-stakes tasks

If a task is internal-only, fits in one session, touches no new PII, and nothing leaves this
machine, skip all of the above — just do it, and log one line in `tasks/quicklog.md`.

## Layout

See the directory map in `CLAUDE.md`.
