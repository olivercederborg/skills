# Skills

Reusable coding-agent skills.

## Included skills

- [`grounding/`](grounding/): verifies technical claims and decisions against current project evidence and primary sources. Invoke it explicitly with `$grounding`.
- [`receiving-review/`](receiving-review/): handles review comments on your own PR or stack. It verifies each claim, then fixes, commits, pushes, replies, and resolves.
- [`review-teammate-pr/`](review-teammate-pr/): reviews someone else's PR with you, then drafts and posts the comments you approve. It also re-reviews after fixes.
- [`pr-review-format/`](pr-review-format/): shared reference for the two review skills (chat format, grounding, agent disclosure, GitHub commands). Install it alongside them.

The review skills share one chat format, built for scanning. Each item is a card with a
one-line summary, a status line and a grounding line, a picture of the flow when
needed, and the code change in context. Every turn ends with one `Next:` question.
Scenario evals live in [`evals/pr-review/`](evals/pr-review/).

`receiving-review` was inspired by Johan Frølich's original skill of the same name.

## Install

```sh
npx skills@latest add olivercederborg/skills
```
