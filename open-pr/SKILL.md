---
name: open-pr
description: Opens a pull request with a short, visual description, or syncs an existing PR's title and description when they've gone stale, for one PR or a whole stack. Use when opening a PR, updating a PR description, or asked whether a PR's title or description still matches the code.
compatibility: Requires git and gh. Uses the repo's stacking tool (for example gt) when it has one.
---

# Open PR

A reviewer should understand why a PR exists and the shape of the change without
reading the diff first. This skill writes that description when a PR opens, and brings
it back in line with the code whenever it drifts.

<!-- toolkit-format:start (synced from shared/format.md by scripts/sync-format.sh; edit there) -->
## Chat format

The user thinks visually and scans. They understand a problem through its flow and the
shape of the code.

**Cards.** Each item that needs a look is a card, in this order:

1. **Heading**: `### 2/5 · <kind>: <subject>`. The progress count shows what's left,
   and each skill defines its own kinds.
2. **Location**: who raised it (their login), and a linked `path:line`.
3. **Evidence lines**, a few words each:
   - `✅ Verified: <how>`, or `❌ Doesn't hold: <why>`
   - `🔎 Sources: <what was checked>`
   - `⚠️ Unverified: <gap>`, only when a gap remains
4. **A picture**, when the code alone doesn't make the flow clear: a text call tree, a
   failure sequence, a state flow, or a case table.
5. **The change** as a `diff`, with enough context to place it in the flow. That means
   the whole function when it's small, or one block per file in call order, each headed
   by its path.
6. **At most two one-line bullets** for risks or assumptions.

**Severity** for code findings:

- **Blocker**: wrong behavior, missing scope, a failing check, or a broken rule.
- **Should**: slop, scope creep, or a non-idiomatic pattern with a clear better form.
- **Optional**: a real improvement that can wait.

**Turns.**

- **Start with content**: the verdict, a table, a card, or the result.
- **Once per session**: show each piece of code, warning, and `FYI:` only once. List
  tests as one-line cases: `file: scenario → expected ✅`.
- **Only what needs the user**: report what they must look at or decide.
- **One-line bullets.**
- **Tables**: at most four columns, with a few words per cell.
- **Side information**, such as CI noise, goes on one `FYI:` line at the end.
- **End on `Next:`**: finish every turn with one bold `**Next:**` line of at most four
  short options. It is the turn's only question.
<!-- toolkit-format:end -->

Card kinds here, used only in sync mode: **Stale**, **Missing**, **Title**. They describe
the PR's description, not the code.

## 1. Pin the PRs

- **Mode**: **open** when the branch has no PR, or **sync** when it has one. **Stack**
  runs the chosen mode on every PR in the stack, bottom first.
- **Diff**: each PR against its parent branch, not against the default branch.
- **Rules**: read the repo's version-control and PR guidance, and its PR template if it
  has one.
- **Kit output**: when available, collect
  - the ticket's **Not in scope** section (from `scope-grill`);
  - the latest `ready-check` verdict and checks line;
  - the latest `review-loop` result.

**Done when:** each PR's mode, base, diff, template, and linked issue are known.

## 2. Write the description

**With a repo template:** fill every template section in its order, leaving the headings
unchanged, and put the change outline in the section that explains the change.

**Without one:** use this body:

````markdown
[EX-12](link) · [plan](link)

## Why the change

One sentence: the problem this solves and what becomes possible after it ships.

## Special things to note

- 1–3 bullets: reviewer warnings, migrations, compatibility, deliberate omissions, or
  surprising decisions. Write "None." when there are none.

## Change outline

One short line of context, then the view:

```diff
 exportJob
   exportAccount
+    retry(publish, { times: 3 })
```

## Not in scope

- **JSON export**: the request is CSV only. Revisit when a consumer needs JSON.

## Evidence

✅ typecheck · ✅ lint · ✅ tests 12/12 · review-loop: Clean (round 2)
````

**Change outline.** Use the smallest set of views that explains the change, and order
them to tell the story:

- data or API contract changes
- key types
- pseudocode for the changed behavior
- a shallow file tree of changed responsibilities
- the component tree
- the call tree or data flow

Use `diff` for a change to an existing shape, and a full block when the shape is mostly
new. Leave out views that didn't change. Diagrams are plain text, so they render on
GitHub and in Slack.

**Other rules:**

- **Not in scope** and **Evidence** appear only when there is content for them.
- **Link issues and plans** rather than copying them. Use the repo's issue-linking
  phrase (for example `Closes EX-12`).
- **UI changes**: when the diff changes UI and a `pr-ui-artifacts` skill is installed,
  offer screenshots.
- **The title** says the outcome in the imperative, in under 70 characters.
- **Scope check**: if the diff mixes unrelated outcomes or is too big to review, say so
  and offer `scope-pull-request` before opening.
- **Describe, don't review.** Code review belongs to `ready-check` and `review-loop`.
  When no recent `ready-check` verdict exists, add `ready-check first` to the `Next:`
  options. Put known gaps in **Special things to note**. Use "Part of" instead of
  "Closes" when the issue isn't fully done.

**Done when:** every section is filled or omitted on purpose, and the outline covers
every behavior change in the diff.

## 3. Sync an existing PR

1. **Read** the current title, description, diff against the parent, and commits.
2. **Check each section** against the diff:
   - **Stale**: it describes code or behavior that's no longer in the diff.
   - **Missing**: behavior in the diff that no section covers, or a template section
     left out.
   - **Title**: the title no longer states the outcome.
3. **Show the proposed changes** as a `diff` of the description, touching only the stale
   and missing parts. Text a person wrote that is still accurate stays word for word.
4. **Current is a valid result.** When nothing drifted, say **Current** and name what
   was checked.

**Done when:** every section is current, or its update is proposed.

## 4. Publish

- **Show the exact title and body first.** Approval means publish:
  `**Next:** submit draft · submit ready · edit`.
- **Submit with the repo's tooling**: its stacking tool when it has one (for example
  `gt submit`), otherwise `git push` and `gh pr create --title … --body-file …`.
- **Sync** updates with `gh pr edit N --title … --body-file …`.
- **Confirm** the PR shows the new title and body, then share the link.
- **In a stack**, publish only the PRs the user approved, and keep the stacking tool's
  own stack links rather than writing a second copy.

After publishing, end with `**Next:** done · sync later`. When review comments arrive,
`receiving-review` picks up from there.

**Done when:** every approved PR shows its approved title and body, and the links are
shared.
