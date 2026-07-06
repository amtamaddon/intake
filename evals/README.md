# evals/

Regression tests for the harness itself, not for any one task. Two tiers:

- **Deterministic (`E-0xx`)**: pure bash, no LLM involved, runs on every commit that
  touches `scripts/`, `.claude/`, `skills/`, or `templates/` (see the pre-commit hook).
  Each case is a self-contained `run.sh` that builds its own fixture in a temp dir.
- **LLM-judge (`E-1xx`)**: spawns the real verifier subagent headlessly against a frozen
  fixture task and checks its verdict mechanically. Opt-in via `--llm` since it spends
  real tokens and takes longer. Each case has `case.md` (the spawn prompt), `fixture-task/`
  (frozen goal/rubric/inputs/output), and `assert.sh` (a deterministic grader of the
  verdict the LLM produced — the LLM is the judge, the assertion on its output is not).

Run everything deterministic: `evals/run_evals.sh`
Run everything including the judge tier: `evals/run_evals.sh --llm`
Run one case: `evals/run_evals.sh --case E-002--chain-tamper-detected`

## Adding a case

Start from a real bug or near-miss, not a hypothetical. `STATE.md`'s Open Failures and
`skills/_INDEX.md`'s candidate lessons are the two places real failures get recorded first —
when one gets confirmed or fixed, it should get an eval case here so it can never silently
regress. Deterministic cases go directly under `cases/E-0NN--slug/run.sh`. Judge cases need
the three-file structure above; prefer reusing real fixture data from `archive/tasks/` over
inventing synthetic examples, the way E-101 and E-102 both reuse the first dry-run.

## Results

`results/results.jsonl` is append-only and committed — one line per run, so eval history
rides the same audit trail as everything else.
