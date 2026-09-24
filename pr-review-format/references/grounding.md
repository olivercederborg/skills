# Grounding a direction

When the user asks "is this idiomatic?", they mean: was this direction researched, or
assumed? Research every non-trivial fix direction, and every technical decline or
finding, before showing it:

- **Library behavior**: read the installed version's source or type declarations and
  the primary docs. If the repo provides a library-specific grounding skill, run it.
  Otherwise run `grounding` for non-trivial library claims.
- **Repo precedent**: find how the codebase already solves the same problem. Follow
  it, or say why this case differs.
- **Repo rules**: check the conventions and ADRs that cover the touched area.
- **Behavior in doubt**: run a focused reproduction at the PR head.

Scope each claim to its evidence. "Can't happen" needs evidence covering every path.
Otherwise say what was checked and what is assumed. When the user challenges a claim,
re-check it and say plainly what changed.

Report the results on the card's status and grounding lines.

**Done when:** every direction shown names the sources it was checked against, or the
gap it still has.
