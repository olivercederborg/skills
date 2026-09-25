---
name: coding-standards
description: Applies correct-by-construction TypeScript defaults for typed failures, boundary parsing, domain types, module design, real test seams, and type safety. Use when writing or reviewing TypeScript.
---

# Coding standards

Oliver's personal TypeScript defaults.

## Priority

When rules conflict:

1. Follow explicit instructions and repository requirements.
2. Preserve correctness, safety, and debuggability.
3. Apply these standards to new and changed behavior. Migrate touched legacy code only
   when it stays in scope.
4. Fit the repository's architecture. Contain incompatible patterns at the nearest
   boundary.

## Principles

- Represent expected failures as typed values.
- Parse untrusted data before it enters application code.
- Use domain types to prevent invalid states and realistic mistakes.
- Keep domain decisions separate from effect ordering and technology boundaries.
- Prefer composition and deep, cohesive modules with small caller burden.
- Write the minimum code the current behavior needs.
- Deliver the agreed scope. List optional extras for the user instead of building them.
- Before deleting code that looks odd, check its git blame and linked issue: it may be
  intentional.
- Test observable behavior through real seams, with assertions that prove real results.

## References

- Read [Domain values and boundaries](references/domain-values-and-boundaries.md) for typed failures, parsing, secrets, branded values, optionality, and state modeling.
- Read [Modules and effects](references/modules-and-effects.md) for module ownership, services, adapters, persistence, workflows, transactions, and external effects.
- Read [Testing](references/testing.md) when writing, changing, planning, running, or reviewing tests.
- Read [TypeScript style](references/typescript-style.md) for strictness, casts, names, control flow, imports, exports, files, comments, and JSDoc.


## Library idioms

Before adding custom parsing, type utilities, state synchronization, or wrappers, check the relevant library's public APIs. Prefer a supported primitive when it expresses the same behavior with less code. Check compiler configuration when considering manual memoization; in React Compiler projects, add it only for a demonstrated need.

Explain the concrete benefit of a proposed idiomatic rewrite; a different spelling alone is not an improvement.

## Existing code

Inspect the repository before adding a pattern or library. New code uses the stronger pattern, even when repo precedent differs.

**Done when:** each changed behavior was checked against every relevant reference, and any rule you broke is named with its reason.
