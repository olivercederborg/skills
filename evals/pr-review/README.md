# PR review skill evals

These are fake scenarios for `receiving-review` and `review-teammate-pr`. Each one is a
small git repo plus a JSON file that stands in for the GitHub fetch. Rerun them after
editing either skill or `pr-review-format`.

```sh
./setup.sh   # builds throwaway repos in /tmp/pr-review-evals
```

## How to run

Start a fresh agent session, so the agent that edited the skill isn't the one testing
it. Prompt it with:

> Act as the main agent would when the user invokes `/<skill>`. Read the skill's
> `SKILL.md` and everything it links to. The PR lives in
> `/tmp/pr-review-evals/<scenario>`. The JSON file there is the GitHub fetch result:
> use no `gh` and no network. Pretend posts and pushes succeed. Reply with only the
> user-facing chat message, then stop.

Then play the user with short replies ("all as recommended", "lock", "post all") and
check the expected outcomes below. Run each scenario on at least two models.

## 01-receiving-first-round (`/receiving-review`)

- **Items**: 3.
  - #1 is a real retry bug from cubic: Fix.
  - #2 is alex-dev's rename, which `CONTEXT.md` contradicts: Decline, grounded in the
    glossary.
  - #3 is CodeRabbit's JSDoc nit from the review body: Decline, answered with a PR
    comment.
- **Skipped**: the resolved thread, the Vercel comment, and the CodeRabbit walkthrough.
- **Card #1**: has a status line and a grounding line, and shows the fix as a `diff` in
  context.
- **CI**: the unrelated CI failure appears once, as a single `FYI:` line.
- **After fixing**: the test appears as a one-line case, and replies are drafted
  unprompted.
- **Delivery**: `Next:` offers commit, push, reply, resolve. After "yes", thread 2
  stays open for alex-dev.

## 02-teammate-fee-rows (`/review-teammate-pr`)

- **Bugs found**: two. The fee row is keyed on currency rather than fee, and `cursor`
  is ignored.
- **Dropped**: the `toPagination` point, because cubic already raised it. The
  `Dropped` line says so.
- **Unconfirmed**: the cursor finding is marked `⚠️ Unconfirmed` (cursor format), and
  the agent offers to ask it as a question.
- **Turns**: one decision per turn. Drafts come only after every finding is decided,
  rendered as blockquotes.
- **Posting**: "post all" builds one review (event COMMENT, no body), and the PR is not
  approved.

## 03-receiving-new-round (`/receiving-review new round of comments`)

- **Skipped**: PRRT_1 and PRRT_5, where our reply is the latest comment. PRRT_5 uses
  the older `🤖 **[Agent]:**` prefix.
- **Kept**: PRRT_2, where alex-dev replied after our decline. The new request (rename
  the file to `discovery.service.ts`) is re-triaged against the repo's naming. The repo
  has no precedent, so either a decline grounded in that absence or a grounding gap is
  a pass.
- **Defer**: PRRT_4, sam-dev's backoff question. The agent proposes a follow-up issue
  and creates nothing without approval.
- **Resolution**: the agent mentions that PRRT_1 and PRRT_5 are answered but still
  open, and offers to resolve them.
- **Formatting**: table cells stay short, and reviewers are named by their login.
