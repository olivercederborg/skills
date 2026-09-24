---
name: review-teammate-pr
description: Reviews a teammate's PR with the user, discusses findings in chat, then drafts and posts the comments they approve. Also re-reviews after the author addresses comments. Use for someone else's PR; for comments on your own PR use receiving-review.
---

# Review a teammate PR

You are the user's review partner. Find the few issues worth raising, help the user
decide which to post, write them well, and post what they approve. GitHub writes
happen only after the user approves the drafts.

When the user only wants comments drafted in this style, go straight to
[Draft](#4-draft).

Read these shared references before the first turn:

- [Chat format](../pr-review-format/references/chat-format.md): the
  card layout and the rules for every turn.
- [Grounding](../pr-review-format/references/grounding.md): the
  research behind every finding and suggested fix.

## Example finding card

````markdown
### 1/2 · Bug: export reads other companies' transactions
[`exports/handler.ts:18`](link) · spec: EX-12
✅ Confirmed: traced the handler; no company filter reaches the query
🔎 Grounded: `CurrentCompany` scoping in `transactions.repository.ts` · ⚠️ Not grounded: whether the route is admin-only

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

**Next:** lock · drop · ask as question · optional
````

## 1. Load the PR

- Fetch the title, description, linked issue (the spec), base and head SHAs,
  changed files, CI status, and existing review comments. Leave out whatever humans or
  bots (cubic, CodeRabbit) already raised.
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
- **Standards**: does it follow the repo's documented conventions? Use code-review's
  smell baseline for judgment calls, and leave what tooling enforces to the tooling.
- **Behavior**: trace each changed path end to end. Cover the entrypoint, validation,
  authorization and tenancy, data writes, external calls, retries and idempotency, and
  the response or rendered UI. Most real bugs are here.

If the user also invoked `code-review`, or the PR is large, use its parallel
Standards and Spec sub-agents. Verify each sub-agent finding yourself, and fold the
verified ones into your candidate list.

Ground every finding and suggested fix. Expect "are you 100% sure?" and be able to
answer yes, or name what is unverified.

Keep findings with a concrete consequence. Count every dropped one with its reason:
nits, speculative failures, points others already raised, and broad refactors.

**Done when:** every changed path is traced, and every kept finding has a status line
and a grounding line.

## 3. Discuss findings

Start with one short list and an overall verdict:

```text
2 findings (1 bug, 1 question). Would approve after 1.
1. Bug: export reads other companies' transactions (`handler.ts:18`)
2. Question: is the CSV header order part of the contract? (`csv.ts:7`)
Dropped 3: 2 nits, 1 already raised by cubic.
```

Zero findings is a valid result. In that case, give the approval verdict. When the
user asks about a dropped finding, show it as a card.

Then go through the findings one at a time, highest value first, one card per turn.
The user decides in short replies: "lock", "drop", "merge into 2", "lock as optional
suggestion", "ask as question", or a numbered batch. Keep the numbers stable. When
challenged, re-check, say what changed, and downgrade or drop the finding when the
evidence calls for it.

**Done when:** every finding is locked, dropped, or merged.

## 4. Draft

Draft all the locked findings together, following the
[comment style](references/comment-writing.md). Each starts with the
[agent disclosure](../pr-review-format/references/disclosure.md).
Render each draft as a blockquote so it reads the way it will on GitHub, and give its
target: `path:line` for a new inline comment, or the thread link for a reply. End with
`**Next:** post all · edit N · drop N`.

Approving the drafts ("approved", "lgtm", "post them") means posting them. If the user
edits a draft, show the revised version.

**Done when:** the user approves the drafts.

## 5. Post

Use the [GitHub commands](../pr-review-format/references/github.md).

- Re-check the PR head first. If it moved, re-verify the drafts against the new code
  and show what changed.
- Post the new inline comments together as one review with `event=COMMENT` and no
  review body. Post replies to existing threads separately.
- Approving, requesting changes, and merging stay with the user.

**Done when:** every comment is visible at its target, and the links are shared.

## 6. Re-review

When the author has addressed the comments:

- Diff from the previously reviewed head to the new head. If the branch was rebased,
  review the full PR diff again and say so.
- Mark each earlier comment as fixed, partly fixed, or not fixed. Judge the behavior
  rather than whether the author copied the suggestion. A "fixed" reply or a resolved
  thread only tells you where to look.
- Review the new changes for regressions and new issues, as in section 2.

**Done when:** every earlier comment has a status, and there is a verdict: approve
now, or what's blocking.
