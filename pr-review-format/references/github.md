# GitHub commands for PR reviews

Contents: review threads · review bodies, comments, and CI · reply · PR comment ·
resolve · new review with inline comments · verify.

Replace `OWNER`, `REPO`, `N`, and the IDs with real values. Write each body to a file
first. `-F body=@file` and `jq --rawfile` keep Markdown and backticks intact without
shell quoting.

## Review threads

```bash
gh api graphql -f owner=OWNER -f repo=REPO -F number=N -f query='
query($owner:String!,$repo:String!,$number:Int!){repository(owner:$owner,name:$repo){pullRequest(number:$number){
  headRefOid
  reviewThreads(first:100){totalCount nodes{id isResolved isOutdated path line originalLine
    comments(first:50){totalCount nodes{fullDatabaseId author{login} body url createdAt}}}}}}}' \
  --jq '.data.repository.pullRequest'
```

- Filter on `isResolved` locally.
- When a `totalCount` exceeds its page size, paginate before drawing conclusions.
- An outdated thread locates its claim through `originalLine`. Check the claim against
  the current head.
- A thread's first comment `fullDatabaseId` is the reply target. The thread `id` is the
  resolve target.
- Use `fullDatabaseId`, because comment IDs exceed 32 bits.

## Review bodies, conversation comments, and CI

```bash
gh pr view N --json reviews,comments \
  --jq '{reviews: [.reviews[] | {author: .author.login, state, body}], comments: [.comments[] | {author: .author.login, body, url}]}'
gh pr checks N
```

## Reply to a thread

```bash
gh api --method POST repos/OWNER/REPO/pulls/N/comments/COMMENT_ID/replies \
  -F body=@reply.md --jq .html_url
```

## PR comment

A finding with no thread, such as one in a review body, gets a PR comment that quotes
it:

```bash
gh pr comment N --body-file reply.md
```

## Resolve a thread

```bash
gh api graphql -f threadId=THREAD_ID \
  -f query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{isResolved}}}'
```

## New review with inline comments

```bash
jq -n --arg sha HEAD_SHA --rawfile b1 draft-1.md --rawfile b2 draft-2.md '{
  commit_id: $sha,
  comments: [
    {path: "apps/web/src/a.ts", line: 42, side: "RIGHT", body: $b1},
    {path: "apps/web/src/b.ts", line: 10, side: "RIGHT", body: $b2}
  ]
}' > review.json

gh api --method POST repos/OWNER/REPO/pulls/N/reviews --input review.json --jq '{id,state}'
gh api --method POST repos/OWNER/REPO/pulls/N/reviews/REVIEW_ID/events -f event=COMMENT --jq .html_url
```

- `line` is the line in the head file, and it must fall inside a diff hunk.
- Use `side: "RIGHT"` for added and context lines, and `"LEFT"` for deleted lines.
- For a range, add `start_line` and `start_side`.
- The first call creates a pending review. Submitting it with `event=COMMENT` and no
  body posts only the inline comments.
- GitHub allows one pending review per user. If one already exists, list it with
  `gh api repos/OWNER/REPO/pulls/N/reviews` and show it to the user. The user decides
  what happens to it.

## Verify

```bash
gh api repos/OWNER/REPO/pulls/N/reviews/REVIEW_ID/comments --jq '.[] | {path, line, html_url}'
```

After an unclear write result, read the thread or review to see what landed before
retrying. Each comment is posted exactly once.
