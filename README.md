# Admin-Services Harness

An agentic harness for admin-services automation. See `CLAUDE.md` for the full constitution
(roles, model routing, house rules, session protocol).

**Not technical? Start with `HOW-TO-ASK.md` instead** — this file is the operator/engineering
reference; that one explains how to just describe what you need in plain language.

## Running a task

1. `/new-task` — an intake interview, not a form. Describe what you need in plain language; it
   asks clarifying questions until confident, restates its understanding back to you, and only
   writes `goal.md`/`rubric.md`/`plan.md` (fully filled in, nothing left as `FILL-ME`) after you
   explicitly confirm. See `.claude/skills/new-task/SKILL.md`.
2. `/run-task <slug>` — runs the build → verify loop until PASS, a stop condition, or a
   house-rule trigger. Refuses to start if `goal.md` is incomplete (`scripts/check_goal.sh`).
3. If the task's Impact class is `money` or `client-facing`, a human runs `scripts/approve.sh
   <task-dir>` themselves — it explains what's being approved in plain language and asks for a
   typed name, then writes `APPROVAL.md`. No agent can write that file directly (see
   `.claude/settings.json`'s deny rules) — this script doesn't route around that, it's still the
   human's own action, just guided.
4. `/close-session` at the end of every session — updates `STATE.md`, prunes it, tallies lesson
   confirmations.

## Low-stakes tasks

If a task is internal-only, fits in one session, touches no new PII, and nothing leaves this
machine, skip all of the above — just do it, and log one line in `tasks/quicklog.md`.

## Layout

See the directory map in `CLAUDE.md`.
