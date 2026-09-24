---
name: grounding
description: Use when a technical claim or decision needs evidence from current project and primary sources before implementation, review, or architecture work.
---

# Grounding

Ground one evidence key: target, question, environment, relevant version or live state, governing authority, and source. This skill establishes support; project instructions and specialized convention skills remain the decision authority.

Identify the claim from the request and available context. Ask only when a missing decision changes the investigation; continue independent evidence gathering.

## Verify

Use every applicable row:

| Target | Evidence |
|---|---|
| Package or library | Target workspace ownership when imports are relevant; locked and resolved version; exact installed declaration or implementation; peer compatibility only when packages interact. If uninstalled, use immutable first-party source for the selected version and label it uninstalled. |
| Tool or platform | Installed or live version; local configuration; first-party help, source, or current official documentation; live system data when deployed state matters. |
| Concept or architecture | Governing project documentation, specification, ADR, or domain rule; one current same-boundary precedent when synthesis needs it; a primary standard, canonical repository, or minimal reproduction only when local authority is insufficient. |

Comparisons and existence claims may include several targets in one key. State the search scope and date before claiming no alternative exists.

Claims that one option is best, safest, or idiomatic must name the project constraints and compare viable alternatives against them.

Inspect the sources needed to resolve the claim. Expand the search when evidence conflicts or leaves a material gap; stop when further reading would not change the decision. Delegate a bounded question only when independent expertise would help and delegation is authorized.

## Evidence before confidence

Support a substantive recommendation with the evidence it depends on. Use concise prose and source links; distinguish verified behavior, inference, and unresolved questions. A fixed packet or pre-patch announcement is unnecessary.

When an implementation recommendation depends on an uncertain API combination or runtime behavior, check a minimal example against the installed version before calling it a working solution. Label an untested sketch as a proposal. Do not turn an unresolved implementation detail into a claim that an architecture is unsuitable.

Use reversible local experiments to resolve technical uncertainty within the authorized scope. Pause dependent work when the remaining ambiguity affects user intent, security, external effects, or a consequential contract. Continue independent work and state what evidence or decision is missing.

## Reuse

Reuse verified evidence while the target, version, governing constraints and relevant state remain unchanged. Explanation, accepted implementation, comment drafting and final review alone do not require another check. Recheck only what new code, state or conflicting evidence invalidates.

When only the conclusion or uncertainty changes, state the change and remaining uncertainty in one line.

Read [references/evaluation.md](references/evaluation.md) only when the user asks to evaluate this skill.
