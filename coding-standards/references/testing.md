# Testing

Choose the lowest test layer that gives enough confidence in the behavior and its main risks:

- Use focused or property tests for pure behavior.
- Use integration tests for composition, persistence, and boundary translation.
- Use component tests for meaningful UI behavior.
- Use end-to-end tests for critical flows and risks that exist only through full runtime wiring.

Keep behavior matrices at lower layers. Add a thin end-to-end test when full wiring adds material confidence.

## Use real seams

Avoid module mocks such as `vi.mock` and `jest.mock`. Prefer constructor-injected dependencies, Effect services and Layers, local infrastructure, in-memory adapters, or fake external adapters.

Do not add a module mock when a real seam is practical. When changing a module-mocked test, move it toward a real seam when that migration stays within scope. A framework boundary may still need a focused mock when it offers no practical seam.

Assert observable behavior, such as a returned value, typed error, persisted state, emitted event, rendered output, or operation recorded by a fake adapter.

Avoid spy assertions when a stronger result exists. Assert an interaction only when the interaction itself is the contract.

Use a local or real database when schema, query, constraint, or transaction behavior matters.

## Avoid tautological assertions

An assertion must prove an independently known result or invariant.

Do not:

- calculate the expected value with production code
- repeat the implementation algorithm in the test
- assert fixture, mock, or setup values that no behavior changed
- use a snapshot that only repeats an object assembled by the test

Ask:

> If the implementation contains the same defect, can this assertion still pass?

If yes, use an independent oracle, a concrete domain example, or a real invariant. Direct equality is valid when the expected value is independently known.

## Property tests

Use `fast-check` when a property is clearer and stronger than examples. Good candidates include parsers, refined types, state machines, round trips, normalization, idempotence, and lawful combinators.

Tests must not bypass parsers, smart constructors, or invariants. A property must not repeat the implementation as its oracle. Keep reusable generators near their domain module unless the repository has a stronger placement rule.

## How many tests

Write the fewest tests that cover the behavior's distinct cases: the main path, each
boundary, and each failure the change handles. Don't repeat a case at another layer or
with other data that exercises the same branch. Don't add tests for behavior the change
didn't touch. More tests are not better coverage when they prove the same thing twice.

## Test quality

Keep setup deterministic, minimal, and visible. Use fixed clocks, IDs, and random seeds when their values affect behavior.

Test public behavior, not private helpers, component structure, or dependency call order. Test a private detail only when it is part of the contract or no public seam exposes the risk.

Do not write a test that only repeats library or framework behavior. Test application-owned wiring, configuration, serialization, compatibility assumptions, decisions, transformations, validation, and side effects.
