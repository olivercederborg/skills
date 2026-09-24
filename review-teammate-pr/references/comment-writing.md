# Comment style

The author, and often their agent, reads the comment. Both should know what to do
after one read.

- **One concern per comment,** with one bounded request.
- **Match the wording to your certainty:**
  - **Verified bug**: state the condition and the consequence, then the fix: "If X,
    then Y. Could we Z?"
  - **Not fully sure, or unfamiliar code**: ask it as a question, or as something for
    the author to verify.
  - **Optional**: prefix `Non-blocking:`. Most comments are optional.
- **Short**: usually two to four sentences, holding only what the author needs to
  act.
- **Snippets only when needed.** Add one (a `diff`, or a sketch labeled `Target
  shape`) when the fix would otherwise be ambiguous. Use real symbols and installed
  APIs.
- **Tests only when needed.** Ask for one when it's needed to lock in the behavior.
- **Tight scope.** Name adjacent work as a follow-up, and keep the request to the
  change itself.
- **Colleague tone.** State the issue and the ask.

## Examples

Verified bug, small fix:

> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Could we keep the empty value controlled?
>
> ```diff
> - value={displayedCategoryId ?? undefined}
> + value={optimisticCategoryId ?? ""}
> ```
>
> The Combobox ignores a reset to `undefined`, so after a failed first selection the
> old code stays displayed.

Verified bug, less obvious:

> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> This query has no `companyId` filter, so an export returns every company's
> transactions in the date range. Could we scope it with `CurrentCompany`, like
> `transactions.repository.ts` does? A test with two companies would lock this in.

Unsure:

> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Question, non-blocking: the CSV columns are now built from `Object.keys(row)`. Do
> any consumers rely on the old header order? If so, an explicit column list would
> keep it stable.

Optional cleanup:

> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Non-blocking: you should be able to replace this hand-written stub with
> `Layer.mock`.
