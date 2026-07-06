# GOAL: Dry-run — extract fields from a synthetic internal memo

- **Task ID:** 2026-07-06--dry-run
- **Impact class:** internal
- **Budget:** 3 iterations, 15 minutes wall-clock

## 1. End State
`output/summary.md` exists containing exactly three fields — Requester, Amount, Due Date — each
with a value copied verbatim from `inputs/memo.txt`, and each line ending in a bracketed
source note, e.g. `Requester: J. Alvarez [memo.txt]`.

## 2. Verification Method
A stranger with only `output/summary.md`, `inputs/memo.txt`, and `rubric.md` checks: all three
fields present, each value matches the memo exactly (no paraphrasing, no reformatting of the
dollar amount or date), and each line cites `[memo.txt]`.

## 3. House Rules — things that must NEVER happen
- Never invent a field value not present in `inputs/memo.txt`.
- Never contact anyone; this is a synthetic, internal-only exercise.

## 4. Stop Conditions
- Max iterations: 3 (see Budget).
- No progress after 2 consecutive iterations with the same failed criteria.
- Wall-clock cap: 15 minutes from TASK START.
- Any house-rule contact: stop and escalate immediately.
