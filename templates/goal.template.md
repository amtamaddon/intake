# GOAL: <task title>

- **Task ID:** YYYY-MM-DD--<slug>
- **Impact class:** FILL-ME   <!-- one of: internal | money | client-facing.
                                 money/client-facing => human approval gate required, see CLAUDE.md -->
- **Budget:** FILL-ME         <!-- max iterations (default 3), wall-clock cap -->
- **Tags:**                   <!-- optional: payer + code for claims work, e.g. "aetna CO-197".
                                    Feeds the episodic index and procedure lookup. Omit if not applicable. -->

## 1. End State
FILL-ME
<!-- What exists when this is done, described as an inspectable artifact.
     Not "process the packet" but "output/intake-summary.md exists containing
     fields X, Y, Z, each traceable to a source page." -->

## 2. Verification Method
FILL-ME
<!-- How a stranger with only the artifact + rubric.md decides pass/fail.
     Must be checkable without access to the builder's reasoning. -->

## 3. House Rules — things that must NEVER happen
FILL-ME
<!-- e.g. "Never send anything to a client address." "Never write PII outside
     tasks/<id>/." Violating a house rule = immediate stop + escalate. -->

## 4. Stop Conditions
FILL-ME
<!-- When to halt even if not done: max iterations hit, no progress after N,
     budget exhausted, any house-rule trigger, anything requiring the human. -->
