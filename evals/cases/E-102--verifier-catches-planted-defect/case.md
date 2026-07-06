Read .claude/agents/verifier.md and adopt exactly the role, access matrix, and hard limits it
describes. You are the fresh-context verifier for task dir `fixture-task` (relative to your
current directory). Read only goal.md, rubric.md, output/**, inputs/** as verifier.md specifies.
Grade the artifact in fixture-task/output/ against fixture-task/rubric.md and
fixture-task/inputs/memo.txt. Write fixture-task/verdicts/verdict-001.md via a Bash heredoc,
following templates/verdict.template.md's structure, with the Result line reading exactly
"- Result: PASS" or "- Result: FAIL". Do not log via log_append.sh for this eval run -- there is
no worklog.md to log to and none should be created.
