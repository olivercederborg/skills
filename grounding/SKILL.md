---
name: grounding
description: Use when a technical claim or decision needs evidence from current project and primary sources before implementation, review, or architecture work.
---

# Grounding

Ground one evidence key: target, question, environment, relevant version or live state, governing authority, and source. This skill establishes support; project instructions and specialized convention skills remain the decision authority.

If the key cannot be identified from the request and current context, ask one focused question and stop.

## Verify

Use every applicable row:

| Target | Evidence |
|---|---|
| Package or library | Target workspace ownership when imports are relevant; locked and resolved version; exact installed declaration or implementation; peer compatibility only when packages interact. If uninstalled, use immutable first-party source for the selected version and label it uninstalled. |
| Tool or platform | Installed or live version; local configuration; first-party help, source, or current official documentation; live system data when deployed state matters. |
| Concept or architecture | Governing project documentation, specification, ADR, or domain rule; one current same-boundary precedent when synthesis needs it; a primary standard, canonical repository, or minimal reproduction only when local authority is insufficient. |

Comparisons and existence claims may include several targets in one key. State the search scope and date before claiming no alternative exists.

Claims that one option is best, safest, or idiomatic must name the project constraints and compare viable alternatives against them.

Inspect only sources needed for the key, with at most one local precedent and one primary external source per target. Stop when the required sources are verified or one decision-relevant uncertainty remains. Use at most one specialist agent for one unresolved question.

## Publish before acting

Publish this packet before the first implementation patch or substantive recommendation:

```text
Grounding
- Target: <target, question, and environment>
- Evidence: <governing source; current version or state and exact source; relevant precedent>
- Evidence supports: <direct evidence or project-specific synthesis>
- Uncertainty: <none or one decision-relevant question>
```

Implementation can proceed only when no remaining uncertainty could change the selected API, pattern, or behavior.

## Reuse

If the current packet covers the evidence key, reuse it silently. Do not repeat evidence checks or publish another full packet. Explanation, accepted implementation, comment drafting, and final review do not change the key.

When only the conclusion or uncertainty changes, state the change and remaining uncertainty in one line.

Read [references/evaluation.md](references/evaluation.md) only when the user asks to evaluate this skill.
