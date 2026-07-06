---
name: new-task
description: Start a new piece of work by interviewing the requester in plain language — no jargon, no forms to fill in themselves. Use whenever someone describes something they need done that isn't a trivial quicklog-eligible task.
---

You are conducting an intake interview, not handing someone a form. The requester may not know
what a "goal.md" or an "Impact class" is, and they never need to. Your job is to end up
**at least 95% sure you understand exactly what they want** before anything gets written or built
— and to get there by asking, not by guessing.

## 1. Understand before you draft anything

Ask the requester, in your own words, what they need — if they haven't already said. Then make
sure you have real, specific answers (not assumptions) to each of the following, asking follow-up
questions wherever the answer is vague, implied, or could go more than one way:

- **What should exist when this is done?** Get something concrete and checkable, not a vibe. If
  they say "handle the intake packet," ask what "handled" produces — a summary, a filled form, a
  yes/no decision, something else — and where it should end up.
- **How would you (or anyone) know it was done right?** What would make them reject the result?
- **Anything that must never happen?** Explicitly ask about contacting people directly, spending
  or moving money, and sensitive data — don't assume "obviously not" covers it; ask.
- **Does this involve money, or a client/customer directly?** This determines whether a human has
  to sign off before it's considered finished — tell them plainly: *"Since this touches
  [money/a client], you'll need to approve the result yourself before it's done — I'll show you
  how when we get there."* If it's neither, say so and note it can close out without that step.
- **What source material does this work from?** If they mention specific files, ask them to share
  the file(s) or a path; save whatever they provide into the task's `inputs/` folder.
- **What should happen if something's ambiguous or ambiguous mid-way?** Default, if they don't
  have a preference: try up to 3 times, then stop and ask a human rather than guess.

**Never fill in a plausible-sounding answer because it's probably what they meant.** If you're not
genuinely confident, ask one more question. Guessing here is exactly the failure mode this whole
harness exists to prevent.

## 2. Confirm before anything is written

Once you believe you understand, **say it back in plain English** — a few sentences, not
technical formatting — covering: what you'll produce, how you'll know it's right, what you'll
never do, and whether human sign-off applies. Ask directly: *"Did I get that right? Anything to
change?"*

Do not proceed to step 3 until they've explicitly confirmed. If their answer reveals a gap,
correct your understanding and say it back again — repeat until confirmed. This confirmation is
the actual substance of "95% sure," not a formality to rush past.

## 3. Check episodic memory for precedent

Before writing anything, run `python scripts/recall.py find "<key terms from the request>"` (and
`recall.py failures "<key terms>"` if the domain suggests past failures are likely, e.g. a payer
denial code). If there's a relevant precedent — a similar past task, a prior failure mode, a
realistic iteration count — fold it into `plan.md` and the rubric in the next step. Note each
result's status (`active`/`done`/`archived`) explicitly when citing it; a done task from three
months ago is not the same kind of precedent as one still active. If nothing relevant turns up,
say so and move on — this step is a lookup, not a requirement to find something.

## 4. Now do the technical translation — the requester doesn't need to see this part

Once confirmed:

1. Compute the task dir: `tasks/<YYYY-MM-DD>--<slug>/` (pick a short, sensible slug from what they
   described). Create it with `inputs/`, `output/`, `verdicts/`.
2. Write `goal.md` in full — no `FILL-ME` left anywhere — translating the confirmed
   understanding into End State, Verification Method, House Rules, and Stop Conditions. Set Impact
   class (`internal` / `money` / `client-facing`) from what was confirmed, not a guess. Set Budget
   to 3 iterations / 30 minutes unless they said otherwise. If the task involves a payer/denial/
   resubmission, add a `- **Tags:**` line naming the payer and code, and check
   `scripts/find_procedure.sh` for a governing procedure (see procedures/_INDEX.md once Phase 4
   lands).
3. Write `rubric.md` yourself, as the planner, from the confirmed Verification Method — concrete,
   checkable criteria a stranger could apply. This must be frozen before `/run-task` runs; don't
   let it get written or adjusted after seeing output later.
4. Write a draft `plan.md` — your own proposed approach for the builder to follow — since you (the
   main session) are the planner here, not the builder. Fold in any precedent from step 3.
5. Save anything the requester shared into `inputs/`.
6. Create an empty `worklog.md` — its first real content must come from `scripts/log_append.sh`,
   never a direct write.

## 5. Hand back, in plain language

Tell the requester, in a sentence or two: what you've set up, and that you're ready to start
whenever they say go (`/run-task`). Do not show them raw `goal.md` syntax unless they ask to see
it — the plain-English confirmation in step 2 already was the real review.

Do not run `scripts/check_goal.sh` here — that happens automatically as the first step of
`/run-task`. Since you filled in every section yourself from a confirmed understanding, it should
already pass; if it doesn't, that's a signal you missed something in the interview, not a reason
to route around the check.
