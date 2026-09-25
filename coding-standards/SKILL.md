---
name: coding-standards
description: Correct-by-construction TypeScript defaults for typed failures, boundary parsing, domain modeling, module design, real test seams, and TypeScript safety. Use when implementing or reviewing TypeScript behavior.
---

# Coding standards

Use these standards as Oliver's personal TypeScript defaults. Explicit instructions and repository-local standards take priority.

## Priority

When rules conflict:

1. Follow explicit instructions and repository requirements.
2. Preserve correctness, safety, and debuggability.
3. Apply these standards to new and meaningfully changed behavior.
4. Keep unrelated code unchanged unless the task includes a broader migration.
5. Fit the repository's architecture. Contain incompatible patterns at the nearest boundary.
6. Record lasting architectural trade-offs in the repository's chosen decision record.

## Principles

- Represent expected failures as typed values.
- Parse untrusted data before it enters application code.
- Use domain types to prevent invalid states and realistic mistakes.
- Keep domain decisions separate from effect ordering and technology boundaries.
- Prefer composition and deep, cohesive modules with small caller burden.
- Write the minimum maintainable code. Do not add speculative abstractions.
- Deliver the agreed scope. List optional extras for the user instead of building them.
- Before deleting code that looks odd, check its git blame and linked issue: it may be
  intentional.
- Test observable behavior through real seams. Avoid module mocks, spies, and tautological assertions.
- Keep ownership and names clear to humans and agents.

## References

- Read [Domain values and boundaries](references/domain-values-and-boundaries.md) for typed failures, parsing, secrets, branded values, optionality, and state modeling.
- Read [Modules and effects](references/modules-and-effects.md) for module ownership, services, adapters, persistence, workflows, transactions, and external effects.
- Read [Testing](references/testing.md) when writing, changing, planning, running, or reviewing tests.
- Read [TypeScript style](references/typescript-style.md) for strictness, casts, names, control flow, imports, exports, files, comments, and JSDoc.

Read each relevant reference. Skip unrelated references.

## Library idioms

Before adding custom parsing, type utilities, state synchronization, or wrappers, check the relevant library's public APIs. Prefer a supported primitive when it expresses the same behavior with less code. Check compiler configuration when considering manual memoization; in React Compiler projects, add it only for a demonstrated need.

Explain the concrete benefit of a proposed idiomatic rewrite; a different spelling alone is not an improvement.

## Existing code

Inspect the repository before adding a pattern or library. Do not copy a weaker pattern into new code only for consistency. Change a touched legacy path only when the migration stays within scope.
