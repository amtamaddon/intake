# MEMORY — always-loaded operational memory
<!-- Cap: 4000 characters. Written ONLY via scripts/memory_update.sh.
     Current size is stamped by the script; do not hand-edit. -->
Last updated: 2026-07-06 | Size: 951/4000 chars

## Environment & substrate
- Custom `.claude/agents/*.md` only resolve when the Claude Code session root IS this directory, not a parent. [2026-07-06--dry-run | confirmed 2026-07-06]

## Operational rules that bite
(none yet — candidates are promoted here from STATE.md's Verified Facts at /close-session, once a fact has held for 3+ sessions or 30+ days and is still load-bearing)

## Domain constants
- Claims flow provider -> payer (CPT codes, billed amounts, payer IDs). Framing is provider/payer, never client/patient. [2026-07-06]

## Pointers (where to look, not what's there)
- Past tasks: `scripts/recall.sh` | Payer procedures: `scripts/find_procedure.sh`
- Evicted memory lines: `archive/MEMORY-archive.md`
