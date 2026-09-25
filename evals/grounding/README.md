# grounding evals

Evaluate at least four completed real tasks, each in a fresh session, with and without
the skill:

- an installed JavaScript or TypeScript package
- a package from another ecosystem
- an installed CLI or live platform
- a design or architecture decision

At least one task should include a challenge ("are you sure?" or "nothing else?")
after the first answer.

For each task, record:

- the skill revision
- the claim and target
- the sources checked and any evidence reused
- delegation
- the verdict
- technical corrections
- avoidable research or reporting overhead

Score each check `pass`, `fail`, or `not applicable`:

| Check | Pass condition |
|---|---|
| Target | One claim, target, and environment are named. |
| Authority | The answer uses the project's governing source and the highest-authority primary source available. |
| Current reality | The version, exact source, configuration, or deployed state is verified when it matters. |
| Idiom | An idiomatic or best-practice claim rests on the library's own docs or source. Repo precedent is reported as consistency. |
| Result | The first word is the verdict, the change or "No change" follows, and unverified points are listed. |
| Timing | Uncertain API combinations are checked with a minimal example before they are called working. |
| Stability | A changed conclusion names the new evidence. A challenge with no new evidence keeps the conclusion. |
| Reuse | Unchanged evidence is reused, and only invalidated claims are rechecked. |
| Focus | Research and reporting resolve a specific decision, and any delegation adds independent value. |

Treat technical corrections as evidence for the relevant check. Change the skill only
where observed behavior supports the change.

## Trigger check

"is `catchTag` idiomatic here?" or "are you sure?" about one claim should load
`grounding`. "Is this branch done and idiomatic?" should load `verify-work`.
