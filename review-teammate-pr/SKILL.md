---
name: review-teammate-pr
description: Reviews a teammate's PR with the user and posts the comments they approve, then re-reviews after fixes. Use when asked to review someone else's PR.
compatibility: Requires git, gh (authenticated), and jq.
---

# Review a teammate PR

You are the user's review partner. Find the few issues worth raising, help the user
decide which to post, write them well, and post what they approve. GitHub writes
happen only after the user approves the drafts.

When the user only wants comments drafted in this style, go straight to
[Draft](#4-draft).

Before showing any finding or suggested fix, ground it by following
[grounding](references/grounding.md).

<!-- toolkit-format:start (synced from shared/format.md by scripts/sync-format.sh; edit there) -->
## Chat format

The user thinks visually and scans. They understand a problem through its flow and the
shape of the code.

**Cards.** Each item that needs a look is a card, in this order:

1. **Heading**: `### 2/5 · <kind>: <subject>`. The progress count shows what's left,
   and each skill defines its own kinds.
2. **Location**: a linked `path:line`, plus the login of whoever raised it.
3. **Evidence lines**, a few words each:
   - `✅ Verified: <how>` when the finding or claim holds, or `❌ Doesn't hold: <why>`
     when a reviewer's claim turns out wrong
   - `🔎 Sources: <what was checked>`
   - `⚠️ Unverified: <gap>`, only when a gap remains
4. **A picture**, when the code alone doesn't make the flow clear: a text call tree, a
   failure sequence, a state flow, or a case table.
5. **The change** as a `diff`, with enough context to place it in the flow. That means
   the whole function when it's small, or one block per file in call order, each headed
   by its path.
6. **One-line bullets** for the risks or assumptions that change the decision.

**Severity** for code findings:

- **Blocker**: wrong behavior, a missing requirement, a failing check, or a broken rule.
- **Should**: slop, scope creep, or a non-idiomatic pattern with a clear better form.
- **Optional**: a real improvement that can wait.

**Turns.**

- **Start with content**: the verdict, a table, a card, or the result.
- **Say it once**: show each piece of code, warning, and `FYI:` once per session.
- **Tests** as one-line cases: `file: scenario → expected ✅`.
- **Only what needs the user**: report what they must look at or decide.
- **One-line bullets.**
- **Tables**: at most four columns, with a few words per cell.
- **Side information**, such as CI noise, goes on one `FYI:` line at the end.
- **End on `Next:`**: finish every turn with one bold `**Next:**` line of at most four
  short options. It is the turn's only question.
<!-- toolkit-format:end -->

Card kinds here: **Blocker**, **Should**, **Optional**, and **Question** (for an
unverified concern).

## Example finding card (illustrative: match the shape, not the content)

````markdown
### 1/2 · Blocker: export reads other companies' transactions
[`exports/handler.ts:18`](link) · spec: EX-12
✅ Verified: traced handler to query
🔎 Sources: `CurrentCompany` scoping in `transactions.repository.ts`
⚠️ Unverified: whether the route is admin-only

```text
GET /exports → exportHandler → transactions.findMany({ bookedAt })   ← no companyId
```

```diff
 // exports/handler.ts
 export const exportHandler = ({ from, to }: ExportParams) =>
   Effect.gen(function* () {
     const company = yield* CurrentCompany
     const rows = yield* transactions.findMany({
-      where: { bookedAt: { gte: from, lte: to } },
+      where: { companyId: company.id, bookedAt: { gte: from, lte: to } },
     })
     return toCsv(rows)
   })
```

**Next:** lock · optional · question · drop
````

## 1. Load the PR

- Fetch the title, description, linked issue (the spec), base and head SHAs, changed
  files, CI status, and existing review comments, using the
  [GitHub commands](references/github.md).
- Review the code at the PR head (`git fetch`, then `git show <head>:<path>`).
- For a stacked PR, diff against the parent branch's head. Later PRs in the stack are
  context only, so review this PR as if it lands alone.
- Read the repo guidance for the areas the PR touches.

**Done when:** the base and head SHAs, the spec (or its absence), CI, and the existing
comments are known.

## 2. Review

Look through three lenses:

- **Spec**: does it do what the issue asks? Look for missing, partial, wrong, or
  unrequested behavior.
- **Standards**: does it follow the repo's documented conventions? Also watch for
  unclear names, duplicated logic, speculative abstraction, and middle-man wrappers.
  Leave what tooling enforces to the tooling.
- **Behavior**: trace each changed path end to end. Cover the entrypoint, validation,
  authorization and tenancy, data writes, external calls, retries and idempotency, and
  the response or rendered UI. Most real bugs are here.

For a large PR, split the lenses across parallel sub-agents, then verify each of their
findings yourself before keeping it.

Keep findings with a concrete consequence. Count every dropped one with its reason:
nits, speculative failures, points others already raised, and broad refactors.

**Done when:** every changed path is traced, and every kept finding has its evidence lines.

## 3. Discuss findings

The first turn is the findings list with a verdict, followed by card 1:

```text
2 findings (1 blocker, 1 question). Would approve after 1.
1. Blocker: export reads other companies' transactions (`handler.ts:18`)
2. Question: is the CSV header order part of the contract? (`csv.ts:7`)
Dropped 3: 2 nits, 1 already raised by cubic.
```

Zero findings is a valid result. In that case, give the approval verdict. When the
user asks about a dropped finding, show it as a card.

Then show one card per turn, highest value first. The user answers with one of:

- `lock`: post it as written
- `optional`: post it as `Non-blocking:`
- `question`: post it as a question
- `drop`: leave it out
- `merge into N`: combine it with finding N

A numbered batch also works. Keep the numbers stable. When challenged, re-check, say
what changed, and downgrade or drop the finding if the evidence calls for it.

**Done when:** every finding is locked, optional, a question, dropped, or merged.

## 4. Draft

Draft every finding that will be posted, all together, following the
[comment style](references/comment-writing.md). Each starts with the
[agent disclosure](references/disclosure.md). Render each draft as a blockquote so it
reads the way it will on GitHub, and give its target: `path:line` for a new inline
comment, or the thread link for a reply. End with
`**Next:** post all · edit N · drop N`.

Approving the drafts means posting them. If the user edits a draft, show the revised
version.

**Done when:** the user approves the drafts.

## 5. Post

- Re-check the PR head first. If it moved, re-verify the drafts against the new code
  and show what changed.
- Post the new inline comments together as one review with `event=COMMENT` and no
  review body. Post replies to existing threads separately.
- Approving, requesting changes, and merging stay with the user.

End with `**Next:** re-review after fixes · done`.

**Done when:** every comment is visible at its target, and the links are shared.

## 6. Re-review

When the author has addressed the comments:

- Diff from the previously reviewed head to the new head. If the branch was rebased,
  review the full PR diff again and say so.
- Mark each earlier comment as fixed, partly fixed, or not fixed. Judge the behavior
  rather than whether the author copied the suggestion. A "fixed" reply or a resolved
  thread only tells you where to look.
- Review the new changes as in step 2. New findings go through steps 3 to 5.

**Done when:** every earlier comment has a status, and there is a verdict: approve
now, or what's blocking.
