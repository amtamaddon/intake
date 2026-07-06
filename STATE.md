# STATE — read at session start, updated only via /close-session

Last updated: 2026-07-06 | Line count: 58/200

## 1. Verified Facts
- The full build->verify->fail->iterate->pass->close-session loop works end to end against real
  subagents (not simulated) — 2026-07-06--dry-run — 2026-07-06.
- Custom `.claude/agents/*.md` are only discoverable when Claude Code's session root IS this
  harness directory — a session rooted at a parent directory cannot spawn `builder`/`verifier`/
  `extractor` by name — 2026-07-06.
- Real domain is healthcare revenue cycle management (RCM): claims flow from providers to
  insurers/payers (CPT codes, billed amounts, payer IDs), not provider-to-patient contact.
  README's example and any future task examples should reflect provider/payer, not
  client/patient, framing — 2026-07-06.

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
Built the full memory/context-management/eval-observe layer across 5 phases (Fable-designed,
Sonnet-built, each phase tested against real fixtures before commit): (1) evals/ regression
suite (9 deterministic cases) + a pre-commit hook gating any change to scripts/.claude/skills/
templates/evals; (2) MEMORY.md, always-loaded 4000-char-capped durable memory, distinct from
CLAUDE.md (static) and STATE.md (pruned session residue), written only via memory_update.sh;
(3) memory/episodes.db, a SQLite+FTS5 episodic index over past tasks (derived/rebuildable, never
a second source of truth -- flat files win on disagreement), queried via recall.py; (4)
procedures/, domain RCM fulfillment playbooks separate from skills/, draft-until-human-approved,
looked up via find_procedure.sh; (5) tracing -- trace.jsonl per task, cost computed from
scripts/pricing.tsv, anchored into the hash chain via one TRACE ANCHOR entry per task rather than
interleaved with the decision narrative.

Real bugs found and fixed while building, not hypothetical: `grep -i` + `-F` core-dumps on this
machine's GNU grep 3.0 (worked around with -E + escaping, now in MEMORY.md); a `set -e` gotcha in
an eval script itself (unguarded `cmd; rc=$?` aborts before rc=$? is set); Python's stdout
defaulted to cp1252 on this Windows machine, mangling em-dashes on display only (data was stored
correctly). Also evaluated an arxiv paper on "ghost memory" (stale/current facts mixing during
retrieval) -- already defended against by STATE.md's superseded-by convention and procedures/'s
version+status fields; concrete takeaway applied: recall.py and find_procedure.sh always print
status (active/done/archived) explicitly, never as an undifferentiated flat list.

Next: (1) restart Claude Code rooted at this folder (not a parent dir) -- still the standing
blocker for real custom-agent discovery, hasn't happened yet across this whole session; (2)
collect the four real specifics for the client-intake-processing task (fields, source docs,
escalation target, PII rule) and run it for real, which will also answer the open question of
what token/cost data the orchestrator can actually capture per subagent spawn; (3) complete n8n
OAuth and build the one low-stakes Schedule-Trigger workflow already scoped.
