# Skill Registry

| Skill | Purpose | Promoted from | Date |
|---|---|---|---|
| (none yet) | | | |

# Candidate Lessons (not yet skills)

A lesson is promoted once it has **two confirmations from two distinct task IDs** — the same
task confirming itself twice does not count. `/close-session` maintains this table and prompts
for promotion when a lesson crosses the threshold.

| ID | Lesson (one sentence) | First seen (task) | Confirmations (task ids) | Status |
|---|---|---|---|---|
| L-1 | Dollar amounts in `log_append.sh` messages must be single-quoted or bash parameter expansion silently mangles them (`$184.50` -> `84.50`) | 2026-07-06--dry-run | [2026-07-06--dry-run] | candidate |
| L-2 | Verifier's tool restriction doesn't stop it reading `worklog.md`/`plan.md` via Bash — the ban is prompt-level only, not enforced | 2026-07-06--dry-run | [2026-07-06--dry-run] | candidate |
