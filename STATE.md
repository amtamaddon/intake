# STATE — read at session start, updated only via /close-session

Last updated: 2026-07-06 | Line count: 49/200

## 1. Verified Facts
- The full build->verify->fail->iterate->pass->close-session loop works end to end against real
  subagents (not simulated) — 2026-07-06--dry-run — 2026-07-06.
- Custom `.claude/agents/*.md` are only discoverable when Claude Code's session root IS this
  harness directory — a session rooted at a parent directory cannot spawn `builder`/`verifier`/
  `extractor` by name — 2026-07-06.

## 2. General Rules
(none yet — this section holds standing rules that emerged from task experience;
the baseline house rules that apply from day one live in CLAUDE.md)

## 3. Open Failures
- Verifier's tool restriction (no Write/Edit) does not stop it from *reading* worklog.md/plan.md
  via Bash — only a prompt-level instruction currently prevents this. One observed near-miss
  (2026-07-06--dry-run, iteration-2 interim verifier read worklog.md post-verdict, self-disclosed,
  did not affect grading). Not yet hardened with a PreToolUse hook per the don't-overengineer rule
  — revisit if a second, non-benign occurrence happens. — status: open, low severity.

## 4. Lessons Learned
(none yet at confirmed status — two real candidates are being tracked in skills/_INDEX.md with
one confirmation each; see there)

## 5. Last Session Summary
Repo is live at github.com/amtamaddon/intake (private). README rewritten (tagline, Mermaid
flow, guardrails, docs table). Hermes Agent evaluated in depth and rejected (see CLAUDE.md) --
decisive gap is no per-path file-write deny, can't replicate the APPROVAL.md/worklog.md guarantee.

n8n MCP server registered at user scope (2026-07-06), pointing at amtamaddon.app.n8n.cloud --
OAuth completes on next Claude Code restart. n8n integration scoped (not built): self-host
recommended (Execute Command node is disabled on n8n Cloud); first workflow to build is
Schedule Trigger -> Execute Command (`claude -p "/run-task <dir>"`) on one low-stakes internal
task -> Slack message, no approval-branch logic yet. Hard rule for that build: n8n must only
invoke a fixed, non-parameterized command and must never touch approve.sh or the worklog --
notify-only for anything gated. Also evaluated (research only, not built): a Fable/HuggingFace
project visualizing a multi-agent collaboration as an isometric town (Cafe/Courthouse/Printing
Press mapping to message-board/review/publish). Recommendation: worth doing later as a read-only
visualization fed by the existing hash-chained worklog (translate worklog rows to
{agent, location, action, timestamp}), estimated 3-5 days for an MVP with off-the-shelf assets --
not a priority over core task work, and never wire it near the approval-gate logic.

Next: (1) restart Claude Code rooted at this folder (not a parent dir) to fix custom-agent
discovery and complete n8n OAuth; (2) collect the four real specifics for the
client-intake-processing task (fields, source docs, escalation target, PII rule) and run it for
real; (3) once OAuth completes, build the one low-stakes n8n workflow above before anything more
ambitious.
