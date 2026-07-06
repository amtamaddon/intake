---
id: PROC-NNNN                    <!-- stable once assigned, never reused -->
title: <short, specific title>
payer: <lowercase slug, or 'any' for a non-payer-specific procedure>
category: denial-resubmission     <!-- denial-resubmission | eligibility | coding | filing | appeal -->
codes: []                         <!-- CARC/RARC/CPT triggers, the primary lookup key -->
version: 1                        <!-- bump on any body change; git holds the diffs -->
status: draft                     <!-- draft | active | superseded -->
approved_by:                      <!-- human name + date; REQUIRED before status: active -->
effective:
source:                           <!-- the payer bulletin, SOP, or task that prompted this -->
last_used:
---
## When this applies
FILL-ME

## Inputs required
FILL-ME

## Steps
FILL-ME

## Output format
FILL-ME
<!-- exact resubmission/output format, field by field -->

## Escalate instead when
FILL-ME
<!-- conditions where this procedure does NOT apply -->

## Known failure modes
FILL-ME
