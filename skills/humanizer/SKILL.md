---
name: humanizer
description: Strip AI writing tells from prose the builder produces for a human reader — reports, denial-appeal drafts for human review, summaries. Never used to disguise output as human-written when it must be disclosed as AI-assisted; used to make it read like it was written by someone who cared, not a template.
---

## Provenance

Forked from [github.com/blader/humanizer](https://github.com/blader/humanizer) (MIT, actively
maintained) at the user's explicit request, 2026-07-06 — **not** promoted through the normal
two-confirmation lesson pipeline. See `skills/_INDEX.md` for why that's a documented exception,
not a silent one. Adapted here: business-writing framing (the upstream skill's fiction-specific
material — story seeds, character work — is dropped), a two-pass loop instead of the upstream's
multi-pattern scoring apparatus, and one Intake-specific hard rule (never invented facts) that
matters more here than in general writing because the input is billing/claims data.

## When to use / not use

Use when the builder's artifact is prose meant for a human to read as prose — an internal report,
a summary for a human reviewer, a draft appeal letter that a human will personally send. **Do
not** use this to make output *pass as* human-written in a context where AI-assistance must be
disclosed — that's a different, dishonest use this skill was never built for. And it never
overrides the standing house rule: Intake drafts client-facing communication for a human to send,
it doesn't send anything itself, humanized or not.

## Procedure — a two-pass loop, not a swarm

A separate "editor," "critic," and "voice coach" role for this doesn't buy anything an editor
agent wouldn't — the value comes from a *fresh context* doing the critique, not from a persona.
Role-play swarms duplicate context and pay handoff costs at every boundary; a two-pass loop with
a clean second pass gets the same quality at a fraction of the token cost, which matters since
Intake already routes cheap-vs-strong deliberately (see `CLAUDE.md`'s model routing table).

1. **Draft.** Write normally, from the actual input. Do not reach for the rewrite step
   prematurely — a plain first draft is a fine start.
2. **Audit — fresh context, hostile.** Spawn a fresh-context pass (same model, empty history,
   just the draft text and the instruction below) rather than critiquing your own draft in the
   same context you wrote it in — you're anchored on your own framing and will miss what a
   genuinely new reader would catch. Prompt: *"Assume a skeptical editor who is paid per AI-tell
   found. Find every one. List them."* Look specifically for: inflated significance language,
   promotional tone, vague unsourced attributions, overused vocabulary (`showcase`, `landscape`,
   `pivotal`, `delve`, `underscore`), em/en dashes, rule-of-three forced groupings, a formulaic
   "challenges and future outlook" closing, passive-voice hedging, and floating claims not tied to
   a specific person, date, or figure.
3. **Rewrite,** addressing what the audit pass found. The final version contains no em dashes (—)
   or en dashes (–) — treated as a reliable enough tell that it's a hard constraint, not a
   suggestion.
4. **Final check**, in order: did the audit pass actually get incorporated, and does it sound
   like it was written by someone who cared, not a template.

## Hard rule: never invent specifics

The upstream skill's biggest failure mode, adapted for this domain rather than fiction: **never
add a fact, name, date, or event not present in the input.** "Adding soul" to a denial summary or
a claims report by inventing a plausible-sounding detail is not a style improvement, it's a
fabrication — and in a domain built around an audited paper trail, that's categorically worse
than sounding a little stiff. If a sentence needs a specific to land and the input doesn't have
one, cut the sentence; don't supply the specific yourself.

## What actually transfers to business/claims writing

Adapted from the same source material's fiction-writing rules — the fiction-specific parts
(story seeds, prose voice exercises) don't apply here; these do:

- **Visualize first, then abstract.** Don't open with "there are discrepancies in this claim" —
  open with the actual CPT code, the actual billed amount, the actual line in the payer's
  rulebook. Earn the abstraction after the concrete detail, not before it. This is the single
  most transferable rule, because it's exactly backwards from what AI writing defaults to.
- **Crunchy specifics before editorializing.** The actual figure, the actual date, the actual
  code — before you're allowed to characterize what it means.
- **No floating claims.** Every assertion needs a place to stand: which claim, which payer, which
  date. "There appear to be discrepancies" is a floating claim; "the billed amount on line 3
  doesn't match the payer's fee schedule for CPT 99213" is not.
- **Anti-protectiveness.** Don't sand the edges off a real problem to make it sound manageable. If
  a claim is going to be denied, say that plainly before describing what happens next.
- **Action over epiphany.** Show the mismatch; don't narrate that you "identified a discrepancy."
  Let the evidence carry it.
- **Burn the best wood first.** Lead with the thing that actually matters — don't bury the denial
  reason in paragraph three after throat-clearing context.
- **Read it aloud (or have a fresh pass do the equivalent).** If it sounds like a report reading
  itself, it is one.
- **Audit at the end:** "did the actual point come through?" — a better last question than any
  pattern checklist.

## Hall of shame — fill this in with your own examples

The upstream skill's own advice: personal patterns catch more than imported ban lists, because
they're calibrated to your domain and your model's habits. This section starts empty on purpose —
add 5-10 real drafts you've cringed at, what specifically made them read as AI-generated, and the
before/after fix. Nothing fabricated here; this only works if the examples are real.

| # | Before (the tell) | What made it obviously AI | After |
|---|---|---|---|
| _(none yet — add your own)_ | | | |
