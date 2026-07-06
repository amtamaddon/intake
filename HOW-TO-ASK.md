# Asking RSK Intake for something — a plain-language guide

**RSK Intake** is the name for this system. You don't need to know anything technical to use it. You
never need to open, write, or edit a script or a config file. Here's what actually happens.

## 1. Just say what you need

Talk to it like you'd explain the task to a coworker: "I have this client intake packet, pull out
the requester's name, amount, and due date, and flag anything that doesn't match our records.
Don't contact the client — if something's unclear, ask me instead of guessing."

## 2. It will ask you questions before doing anything

Expect a few follow-up questions — what exactly "done" should look like, how you'd know it did the
job right, anything that must never happen, and whether the work touches money or a client
directly. This isn't stalling; it's making sure it doesn't build the wrong thing.

Once it thinks it understands, it will **repeat your request back to you in plain English** and
ask "did I get that right?" Read that summary carefully — that's the actual checkpoint. If
anything's off, say so; it'll correct itself and check again. Nothing starts until you confirm.

## 3. It does the work, then someone else checks it

Once you confirm, it works, then hands the result to a **separate reviewer** — one that never saw
how the work was done, only the finished result — whose whole job is to try to find something
wrong with it. If it finds a problem, the work gets redone and re-checked automatically, up to a
few tries, before anyone needs to step in.

## 4. If it involves money or a client: you sign off, not it

If your request touches money or contacts a client directly, the work is never considered
"finished" by the AI itself — only a human can close that out. When it gets to that point, you'll
be told to run one command yourself:

```
scripts/approve.sh <the task it gives you>
```

It'll show you, in plain language, what's about to be approved and what the independent reviewer
found, then ask you to type your name. That's it — no file editing. This step exists on purpose
and can't be skipped or done on your behalf, by design, even by the AI itself.

## What it will never do

- Contact a client or customer directly on its own.
- Guess at a number, a name, or a fact it isn't sure about — it will ask you instead.
- Call a task "done" by itself when money or a client is involved — that's always your call.
- Move on to build something before you've confirmed it understood you correctly.

## If something feels wrong

Say so, at any point — "wait, that's not what I meant," "stop," "that doesn't look right." It's
built to stop and reconsider rather than push through, and every step it takes is written down in
that task's log for anyone to review afterward.
