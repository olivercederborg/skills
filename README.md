# Skills

Reusable coding-agent skills.

## Included skills

- [`grounding/`](grounding/): verifies technical claims and decisions against current project evidence and primary sources. Invoke it explicitly with `$grounding`.
- [`receiving-review/`](receiving-review/): handles review comments on your own PR or stack. It verifies each claim, then fixes, replies, and resolves.
- [`ready-check/`](ready-check/): tells you whether a branch, PR, or stack is actually done. It checks scope, idiom, standards, slop, tests, verification, and the PR description, gives a done or not-done verdict, and fixes what you approve.
- [`review-loop/`](review-loop/): has Claude and Codex review a change in parallel, checks their findings against the code, fixes what you approve, and re-reviews until it's clean.
- [`review-teammate-pr/`](review-teammate-pr/): reviews someone else's PR with you, then posts the comments you approve. It also re-reviews after fixes.

The two review skills share one chat format, built for scanning. Each item is a card
with a one-line summary, a status line and a grounding line, a picture of the flow
when needed, and the code change in context. Every turn ends with one `Next:`
question. The reference files they share live in [`shared/pr-review/`](shared/pr-review/)
and are symlinked into each skill, so each skill installs self-contained. Scenario
evals live in [`evals/`](evals/), and the review behind this
design is in [`docs/research/`](docs/research/).

`receiving-review` was inspired by Johan Frølich's original skill of the same name.

## Install

```sh
npx skills@latest add olivercederborg/skills
```
