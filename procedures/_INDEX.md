# Procedures Registry

`procedures/` holds domain (revenue cycle management) fulfillment know-how: payer-specific denial
handling, resubmission formatting, eligibility-check sequences. This is different from
`skills/`, which holds harness-operational playbooks promoted from lessons ("how Intake works
better"). Procedures are typically authored from external authority (a payer bulletin, a
biller's existing SOP), not earned through the two-confirmation lesson pipeline — a procedure
can be valid before any task has ever used it.

## Layout

```
procedures/
  <payer>/<slug>.md      -- payer-specific, e.g. procedures/aetna/denial-CO-197.md
  any/<slug>.md          -- payer 'any' = generic RCM procedure, not payer-specific
```

## Activation

New or revised procedures start at `status: draft` in their frontmatter. `scripts/find_procedure.sh`
returns only `status: active` procedures by default (`--include-draft` to see drafts too), so an
unapproved procedure structurally never reaches a builder through the sanctioned lookup path.
Flipping `draft` to `active` requires a human: the planner asks by name ("PROC-000N drafted from
<source> — review and approve?"), and on yes the human (or the planner, once told yes) sets
`approved_by: <name>, <date>` and `status: active` directly in the file — no separate approval
script; git history is the audit trail for this, the same way it is for any procedure edit.

## Registry

| ID | Payer | Title | Status | Version | Path |
|---|---|---|---|---|---|
| (none yet) | | | | | |

See `templates/procedure.template.md` for the file format. Each procedure logs its own id+version
when a builder applies it (`applied PROC-000N vX` via `log_append.sh`), so any past task's
worklog plus `git log -- <procedure path>` reconstructs exactly which text was followed.
