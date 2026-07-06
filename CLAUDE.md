# Intake — Constitution

This file governs every session working in this repo. Read it, and STATE.md, before doing anything else.

## What this is

**Intake** — an agentic harness for admin-services automation. Real compliance stakes (finance/admin
client data) — the audit trail and the human gate on money/client-facing work are non-negotiable,
not nice-to-haves.

## Substrate

Plain Claude Code. No external framework. Fresh-context isolation comes from custom subagents
(`.claude/agents/*.md`), cost routing comes from the `model:` field on those subagents, and the
human gate is enforced by permission deny rules in `.claude/settings.json` — not by convention.

**Migration triggers** (revisit the substrate decision on evidence, not mood):
- Tasks need to run unattended/scheduled without a human at the terminal. **This trigger has not
  fired and the first answer is NOT a new platform**: run `claude -p "/run-task <dir>"` headless,
  triggered by the OS scheduler (Windows Task Scheduler / cron) — this keeps 100% of the
  enforcement layer (`.claude/settings.json` denies and all scripts apply identically headless).
  Note also that unattended runs are structurally limited to `internal`-class tasks regardless of
  substrate — the human approval gate cannot be satisfied unattended, by design. Only evaluate a
  new platform if OS-scheduler + headless `claude -p` is tried and proves insufficient (e.g. needs
  messaging-platform delivery, cheap-poll wake gating, or multi-day always-on operation).
- An actual context-contamination incident occurs that subagent isolation failed to prevent.
- More than two concurrent long-running workers become routine.

**Hermes Agent** (NousResearch, MIT, github.com/NousResearch/hermes-agent, 210k stars, active) was
evaluated in depth 2026-07 as a candidate and rejected for now — logged here so it isn't
re-litigated from scratch. Real strengths: genuine hard iteration caps (`agent/iteration_budget.py`),
real fresh-context subagent delegation (one-way summary relay, no parent history), a real cron
daemon, and an agentskills.io-compatible skill system. Confirmed, decisive gap: **no per-path
file-write deny mechanism** — its approval system gates terminal command patterns, not native
file-write/patch tools, so Intake's two non-negotiable guarantees (no agent can write
`APPROVAL.md` or `worklog.md`) cannot be replicated without forking the platform. Also gaps: no
audit-trail tamper-evidence, no per-cron-job token/cost budget, no per-delegation model override
(routing table isn't expressible), subagent isolation is in-process/thread-based with no per-path
read restriction (same weakness Intake already has, no improvement). Reconsider only if: Hermes
gains per-path write-deny rules, gains per-delegation model selection, and the OS-scheduler path
above is actually tried and found insufficient.

## Roles and model routing

| Role | Runs as | Model | Why |
|---|---|---|---|
| Planner / Orchestrator | Main session | Strongest available (Opus/Fable) | Writes goal.md, plan.md, the rubric; enforces the loop. Errors here propagate everywhere. |
| Builder | `.claude/agents/builder.md` | Sonnet | Bulk of token spend; executes one bounded iteration against a written goal. |
| Mechanical extractor | `.claude/agents/extractor.md` | Haiku | Judgment-free reformatting/transcription steps only, when the plan explicitly carves one out. |
| Interim verifier (iterations before the last) | `.claude/agents/verifier.md` | Sonnet | Catches most defects cheaply mid-loop. |
| Final verifier (the PASS that counts) | `.claude/agents/verifier.md`, model override | Opus | Verification quality bounds output quality — guard the exit with the strongest model. |
| Sign-off on money / client-facing work | Human, `APPROVAL.md` | — | Non-negotiable. No model tier substitutes for this. |

## Global house rules (apply to every task, in addition to that task's own goal.md house rules)

- Never contact a client directly. All client-facing communication is drafted for a human to send.
- Never write PII in plaintext outside a task's own `inputs/` or `output/` directory.
- Any task with Impact class `money` or `client-facing` requires a human-signed `APPROVAL.md`
  before it can be marked done — enforced mechanically by `scripts/check_done.sh`, not by asking nicely.
- The agent never self-declares a task "done." Only `scripts/check_done.sh` (verifier PASS + approval
  gate) or a human closes a task out.

## Session protocol

1. **Start of session:** read `STATE.md` in full before doing anything else.
2. **During the session:** work through `tasks/`, following `.claude/skills/run-task` for real tasks.
3. **End of session:** run `/close-session` — updates STATE.md's five sections, prunes it back under
   the 200-line cap, and tallies lesson-confirmation counts. Do not end a session without this.

## Quick-task exemption — don't overengineer

A task may skip the entire scaffold (no task folder, no verifier, no loop) **iff all** of the following hold:
- Impact class would be `internal`.
- It fits in one context window / one session.
- It touches no new PII.
- Nothing produced by it leaves this machine.

Log it as one line in `tasks/quicklog.md` (date, what, outcome) and move on. If a quick task fails, or
turns out to touch anything gated, re-run it as a full task — that failure is the signal for the scaffold,
not a hypothetical.

## Directory map

```
CLAUDE.md, STATE.md, README.md   — constitution, memory, orientation
templates/                       — goal/rubric/verdict skeletons
scripts/                         — the enforcement layer (bash)
skills/                          — domain playbooks, promoted after a lesson confirms twice
tasks/<date>--<slug>/            — one folder per real task
archive/                         — pruned STATE.md history, closed-out tasks
.claude/agents/                  — builder, verifier, extractor subagent definitions
.claude/skills/                  — operator commands: new-task, run-task, verify-task, close-session
```
