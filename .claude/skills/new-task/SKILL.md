---
name: new-task
description: Scaffold a new task folder from the templates. Use when starting any real (non-quicklog) piece of work.
---

Given a short slug (kebab-case) and title from the user:

1. Compute the task dir: `tasks/<YYYY-MM-DD>--<slug>/` using today's date.
2. Create it with subdirectories `inputs/`, `output/`, `verdicts/`.
3. Copy `templates/goal.template.md` to `<task-dir>/goal.md`, filling in the Task ID and title —
   leave every `FILL-ME` exactly as-is. Do not guess at End State, Verification Method, House
   Rules, or Stop Conditions on the user's behalf; those are theirs to fill in.
4. Create an empty `<task-dir>/plan.md` and `<task-dir>/rubric.md` (copy
   `templates/rubric.template.md` into the latter, FILL-ME intact).
5. Create an empty `<task-dir>/worklog.md` — the first real content in it must come from
   `scripts/log_append.sh`, never a direct write.
6. Tell the user exactly which sections of `goal.md` still need filling in, and remind them:
   `rubric.md` must be written and frozen *before* `/run-task` is used — not after seeing output.

Do not run `scripts/check_goal.sh` yet — that happens automatically as the first step of
`/run-task`, not here. This skill only scaffolds; it doesn't gate.
