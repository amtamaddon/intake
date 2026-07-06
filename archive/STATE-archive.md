# STATE Archive

Append-only. Everything pruned out of STATE.md lands here, dated. Not read at session start —
this is for audit and deliberate lookups only.

## 2026-07-06 — prior Last Session Summary (superseded)
Harness scaffolding under construction, 2026-07-06. No real task has been run yet.

## 2026-07-06 — prior Last Session Summary (superseded)
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
