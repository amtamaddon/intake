---
name: close-session
description: Run at the end of every session. Updates STATE.md's five sections, prunes it back under the 200-line cap, tallies lesson-confirmation counts, and pushes the audit trail. Do not end a session without this.
---

## 1. Update STATE.md

Before overwriting anything, append the *current* `## 5. Last Session Summary` content to
`archive/STATE-archive.md` under a dated heading — never let a session summary disappear
uncounted.

Then update all five sections based on what actually happened this session:

- **1. Verified Facts** — add any new confirmed fact as `fact — source task id — date`. If a new
  fact supersedes an old one, don't delete the old line: append `(superseded by <new fact>, <date>)`
  to it — it moves to the archive on the next pruning pass, not immediately.
- **2. General Rules** — add any new standing rule that emerged from this session's task
  experience (rules that apply to *all* tasks, not just one). Baseline rules that were already
  known up front belong in CLAUDE.md, not here.
- **3. Open Failures** — add unresolved problems as `symptom — task id — status`. Remove a line
  only by moving it: to Lessons Learned if it resolved into a confirmed lesson, or left as-is if
  still open (it becomes archive-eligible after 30 days untouched — see pruning below).
- **4. Lessons Learned** — do NOT add a lesson here on first occurrence. New lessons go into
  `skills/_INDEX.md`'s candidate table first (see step 2). A lesson only appears in STATE.md once
  it has reached `confirmed` status there.
- **5. Last Session Summary** — overwrite completely with this session's summary, 10 lines or
  fewer: what was worked on, completed, in progress, decisions made, next-session priorities.

## 2. Tally lesson confirmations (skills/_INDEX.md)

For each new candidate lesson observed this session:

- If it's genuinely new: add a row with one confirmation, citing this session's task id.
- If it recurs: append this task id to its Confirmations column — **only if that task id isn't
  already listed** for this lesson (a single task cannot confirm its own lesson twice).
- If a lesson's Confirmations column now lists **two distinct task ids**: stop and ask the user,
  by name, "L-n confirmed twice ([ids]) — promote to a skill?" Do not promote without a yes.
  - On yes: write `skills/<name>/SKILL.md` following the template's structure (Role, When to
    use/not use, Procedure & examples, Output format, Constraints, Known failure modes,
    Anti-patterns, Provenance — the Provenance section must list both confirming task ids and the
    promotion date). Update the Skill Registry table in `skills/_INDEX.md`. Replace the lesson's
    row in the candidate table with a status of `promoted`, and if it had already reached
    STATE.md's Lessons Learned section, collapse that line to a single pointer:
    `L-n → skills/<name>/SKILL.md`.

## 3. Prune STATE.md — mandatory, not optional

Check the line count. The session is **not closed** until the file is at or under the 200-line
cap stated in its own header.

- Any Open Failure untouched for 30+ days: move it to `archive/STATE-archive.md` under a dated
  heading, marked `stale`.
- Any Verified Fact marked superseded in a prior session: move it to the archive with a
  `superseded-by` note.
- Any Lesson already collapsed to a `promoted` pointer: leave the pointer, nothing further to prune.
- Update the header's `Last updated` date and `Line count: n/200`.

The archive is append-only prose and is never read at session start — don't reference it as if it
were live state.

## 4. Persist the audit trail

If this project is under git, commit and push now (`git add -A && git commit -m "session close: <date>" && git push`,
confirming with the user first if a remote isn't already configured). This is the cheap mitigation
for the worklog hash chain being tamper-*evident* rather than tamper-*proof*: a remote holds an
independent copy of every chain state, so a local rewrite doesn't go undetected forever.
