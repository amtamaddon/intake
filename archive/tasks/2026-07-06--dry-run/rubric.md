# RUBRIC: 2026-07-06--dry-run

Written: 2026-07-06, before the build began.

You are grading ONLY the artifact in `output/` against `inputs/` and this rubric.
If you have seen the maker's `plan.md` or `worklog.md`, declare contamination and stop.

## Criteria (each: PASS / FAIL / CANNOT-ASSESS + evidence)

| # | Criterion | How to check |
|---|-----------|--------------|
| 1 | Requester field present and matches memo exactly | Compare `output/summary.md` Requester line to `inputs/memo.txt` |
| 2 | Amount field present and matches memo exactly, including `$` and cents | Compare Amount line to memo's "Amount requested" line |
| 3 | Due Date field present and matches memo's "Needed by" date exactly | Compare Due Date line to memo |
| 4 | Each of the three lines ends with a `[memo.txt]` source citation | Inspect `output/summary.md` formatting |
| 5 | No field present beyond the three specified (no extra invented fields) | Inspect `output/summary.md` for extraneous lines |

## Automatic-fail conditions

- Any house rule from `goal.md` §3 violated.
- Any claim in the artifact not traceable to `inputs/`.
