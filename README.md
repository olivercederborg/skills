# Skills

A small toolkit of coding-agent skills for planning, checking, and reviewing code. The
skills work in Claude Code and Codex, and share one chat format that is built for
scanning.

## Workflow

```text
scope-grill       plan: decide by code impact, keep the MVP small, write "Not in scope"
build             implement the plan in small, verified steps, inside its scope
verify-work       is it done? scope (incl. Not in scope), idiom, standards, slop, tests
review-loop       Claude + Codex review → fix → re-review until clean
open-pr           open the PR with a visual description, or sync a stale one
address-review    handle reviewers' and bots' comments: verify, fix, reply, resolve

review-teammate-pr   review someone else's PR and post the comments you approve
grounding            used by all of the above: check a claim against real evidence
coding-standards     used when writing or checking code: your TypeScript defaults
```

| Skill | Use when |
|---|---|
| [`scope-grill`](scope-grill/) | Planning a change, or scoping an existing spec, ticket, or PR |
| [`build`](build/) | Implementing an agreed plan, spec, or ticket |
| [`verify-work`](verify-work/) | Asking "is this done?", "is it idiomatic?", or "anything left?" |
| [`review-loop`](review-loop/) | Asking for a second opinion, or a review by Claude and Codex |
| [`open-pr`](open-pr/) | Opening a PR, or checking whether a PR's title and description still match the code |
| [`address-review`](address-review/) | Handling review comments on your own PR or stack |
| [`review-teammate-pr`](review-teammate-pr/) | Reviewing a teammate's PR |
| [`coding-standards`](coding-standards/) | Implementing or reviewing TypeScript. `verify-work` applies it too |
| [`grounding`](grounding/) | Verifying a technical claim, or asking "are you sure?" |

## How they fit together

- **One chat format.** Each skill starts with the verdict. It then shows cards with
  `✅ Verified` / `🔎 Sources` / `⚠️ Unverified` evidence lines, a picture of the flow
  when needed, and the code change in context. Every turn ends with one `Next:`
  question. Code findings use one severity scale: Blocker, Should, Optional.
- **One source for shared rules.**
  - The chat format lives in [`shared/format.md`](shared/format.md) and is copied into
    each skill's `SKILL.md`, so it survives context compaction. Keep the copies in sync
    with `scripts/sync-format.sh`, and check them with `scripts/sync-format.sh --check`.
  - Grounding rules come from the `grounding` skill itself.
  - Shared references (`shared/*.md`, `grounding/SKILL.md`) are symlinked into each
    skill's `references/`, so a single installed skill still works on its own.
- **Handoffs.** Each skill's last `Next:` offers the next step in the workflow.

Scenario evals live in [`evals/`](evals/). The review behind this design is in
[`docs/research/`](docs/research/).

The kit also uses these skills from [mattpocock/skills](https://github.com/mattpocock/skills) when they're installed: `codebase-design` (deep modules and seams), `domain-modeling` (`CONTEXT.md` glossary and ADRs), `tdd` (red-green loop), and `diagnosing-bugs` (debug loop). The one-line rules it needs from each are copied into the kit, so it works without them.

`coding-standards` is adapted from dmmulroy's skill of the same name
([dmmulroy/skills](https://github.com/dmmulroy/skills), MIT; see its `NOTICE`).
`address-review` was inspired by Johan Frølich's `receiving-review` skill.
`open-pr`'s default body is modeled on HumanLayer's `visual-pr` skill
([humanlayer/skills](https://github.com/humanlayer/skills)). `scope-grill` adapts the design-tree rounds from Matt Pocock's `grilling` skill
([mattpocock/skills](https://github.com/mattpocock/skills)).

## Install

```sh
npx skills@latest add olivercederborg/skills
```
