# Skill Registry

| Skill | Purpose | Promoted from | Date |
|---|---|---|---|
| `humanizer` | Strip AI writing tells from prose the builder produces for a human reader | **imported**, human-requested — see note below | 2026-07-06 |

**Exception to the two-confirmation rule, documented rather than silent:** skills here are
normally *earned* — promoted only after a lesson is confirmed by two distinct tasks. `humanizer`
is the one deliberate exception: forked from an external, actively-maintained source
(github.com/blader/humanizer) at the user's explicit request, not grown from Intake's own task
history. Its Provenance section says so plainly. This is the same exception pattern
`procedures/` already uses (external-authority content, human-approved, not lesson-earned) —
future externally-sourced skills should follow this precedent rather than quietly skip the
promotion pipeline.

# Candidate Lessons (not yet skills)

A lesson is promoted once it has **two confirmations from two distinct task IDs** — the same
task confirming itself twice does not count. `/close-session` maintains this table and prompts
for promotion when a lesson crosses the threshold.

| ID | Lesson (one sentence) | First seen (task) | Confirmations (task ids) | Status |
|---|---|---|---|---|
| L-1 | Dollar amounts in `log_append.sh` messages must be single-quoted or bash parameter expansion silently mangles them (`$184.50` -> `84.50`) | 2026-07-06--dry-run | [2026-07-06--dry-run] | candidate |
| L-2 | Verifier's tool restriction doesn't stop it reading `worklog.md`/`plan.md` via Bash — the ban is prompt-level only, not enforced | 2026-07-06--dry-run | [2026-07-06--dry-run] | candidate |
