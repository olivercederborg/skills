# Skills

A small toolkit of coding-agent skills for planning, building, checking, and reviewing
code. The skills work in Claude Code and Codex, and share one chat format built for
scanning.

## Workflow

```text
scope-grill → build → verify-work → review-loop → open-pr → address-review

review-teammate-pr    for someone else's PR
grounding             underneath all of them: check a claim against real evidence
coding-standards      underneath build and verify-work: your TypeScript defaults
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
| [`grounding`](grounding/) | Checking one technical claim, or asking "are you sure?" |
| [`coding-standards`](coding-standards/) | Writing or reviewing TypeScript |

## How they fit together

- **One chat format** ([`shared/format.md`](shared/format.md)): the verdict comes first,
  items are cards with `✅ Verified` / `🔎 Sources` / `⚠️ Unverified` lines, code
  findings use Blocker / Should / Optional, and each turn ends with one `Next:` question.
- **One source for each shared rule.** The format is copied into each workflow skill so
  it survives context compaction: run `scripts/sync-format.sh` after editing it, and
  use `--check` to catch drift. Grounding rules live only in the `grounding` skill.
  Shared files are symlinked into each skill's `references/`, so a single installed
  skill works on its own.
- **Handoffs.** Each skill's last `Next:` offers the next step in the workflow.

Scenario evals live in [`evals/`](evals/). The review behind this design is in
[`docs/research/`](docs/research/).

## Credits

- **Matt Pocock's skills** ([mattpocock/skills](https://github.com/mattpocock/skills)):
  - `scope-grill` adapts the design-tree rounds from `grilling`.
  - The kit uses `codebase-design`, `domain-modeling`, `tdd`, and `diagnosing-bugs` when
    they're installed. The one-line rules it needs from them are copied in, so it
    works without them.
- **`coding-standards`** is adapted from dmmulroy's skill of the same name
  ([dmmulroy/skills](https://github.com/dmmulroy/skills), MIT; see its `NOTICE`).
- **`open-pr`**'s default body is modeled on HumanLayer's `visual-pr`
  ([humanlayer/skills](https://github.com/humanlayer/skills)).

## Install

```sh
npx skills@latest add olivercederborg/skills
```
