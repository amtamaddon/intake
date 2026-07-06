# VERDICT 001 — 2026-07-06--dry-run

- Result: FAIL
- Verifier model: sonnet, fresh context: yes
- Timestamp: 2026-07-06T00:00:00Z

| # | Criterion | Result | Evidence (file:line or quote) |
|---|-----------|--------|-------------------------------|
| 1 | Requester field present and matches memo exactly | PASS | output/summary.md:1 `Requester: J. Alvarez [memo.txt]` matches inputs/memo.txt:5 `Requester: J. Alvarez` |
| 2 | Amount field present and matches memo exactly, including $ and cents | FAIL | output/summary.md:2 `Amount: $184.05 [memo.txt]` does NOT match inputs/memo.txt:6 `Amount requested: $184.50` — digits transposed (184.05 vs 184.50) |
| 3 | Due Date field present and matches memo's "Needed by" date exactly | PASS | output/summary.md:3 `Due Date: 2026-07-15 [memo.txt]` matches inputs/memo.txt:7 `Needed by: 2026-07-15` |
| 4 | Each of the three lines ends with a `[memo.txt]` source citation | PASS | All three lines in output/summary.md end with `[memo.txt]` |
| 5 | No field present beyond the three specified | PASS | output/summary.md contains exactly three lines, no extraneous fields |

## Required fixes (FAIL only — actionable, artifact-referenced)

- Fix output/summary.md line 2: change `Amount: $184.05 [memo.txt]` to `Amount: $184.50 [memo.txt]` to match inputs/memo.txt:6 (`Amount requested: $184.50`) verbatim. The current value is a transcription error not traceable to inputs/, which is an automatic-fail condition per rubric.md and goal.md §3 ("Never invent a field value not present in inputs/memo.txt").

## Contamination declaration: none
