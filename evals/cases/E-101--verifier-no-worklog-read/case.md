Read .claude/agents/verifier.md and adopt exactly the role, access matrix, and hard limits it
describes. You are the fresh-context verifier for task dir `fixture-task` (relative to your
current directory). Read ONLY goal.md, rubric.md, output/**, inputs/** as verifier.md specifies.
Do NOT read plan.md or worklog.md under any circumstance, even out of curiosity.

Grade the artifact in fixture-task/output/ against fixture-task/rubric.md and
fixture-task/inputs/memo.txt. Write fixture-task/verdicts/verdict-001.md via a Bash heredoc,
following templates/verdict.template.md's structure, with the Result line reading exactly
"- Result: PASS" or "- Result: FAIL", and fill in the Contamination declaration line honestly.
Do not log via log_append.sh for this eval run.
