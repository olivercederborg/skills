# PR review chat format

These are the shared rules for `receiving-review` and `review-teammate-pr`. Each skill
keeps its own example cards.

Assume the user thinks visually. They understand a problem through its flow and the shape of
the code, and they scan rather than read.

## Card

Every item or finding is a card, in this order:

1. **Heading**: `### 1/3 · <call>: <subject>`. The progress count shows how much is
   left.
2. **Location**: who raised it (their GitHub login, or the name the user calls them),
   a linked `path:line`, and the spec when relevant.
3. **Status**: whether the claim holds. Use one of `✅ Confirmed: <how>`,
   `❌ Doesn't hold: <why>`, or `⚠️ Unconfirmed: <what's missing>`.
4. **Grounding**: `🔎 Grounded: <sources checked>`, plus
   `⚠️ Not grounded: <what>` when a gap remains. Trivial fixes, such as a typo or an
   unused import, carry no grounding line.
5. **Picture**: use one when the code alone doesn't make the flow clear. Pick one
   view: a call tree, a sequence diagram (Mermaid), a state flow, a file tree, or a
   `diff` of one of those. If a `show-me` skill is installed, use its views.
6. **Code**: the change as a `diff`, with enough context to place it in the flow. That
   means the whole function when it's small. A change across files gets one block per
   file, in call order, each headed by its path.
7. **Bullets**: up to two one-line bullets for risks, tradeoffs, or assumptions.
8. **`Next:`**: the closing line, described under Turns.

Keep the status and grounding lines to a few words each, like
`✅ Confirmed: ran both cases at the PR head`. The picture and bullets carry the
details.

## Turns

- **Content first.** The first line of a turn is the table, the card heading, or the
  result.
- **Each thing once per session.** That applies to every piece of code, warning, and
  `FYI:` line. After a fix, show only code the user hasn't seen yet. List new tests as
  one-line cases (`file: scenario → expected ✅`) and show their code on request.
- **Attention only.** Report what the user must look at or decide, and leave empty
  states unsaid.
- **Short bullets.** Each bullet is one line of about 15 words:
  `thing → call: reason`.
- **Narrow tables.** Use at most four columns with a few words per cell, so the table
  isn't cut off.
- **One `FYI:` line.** Side information, such as CI noise or unrelated findings, goes
  on a single line at the end.
- **One decision per turn.** Each skill states the batch answers it accepts.
- **End on `Next:`.** The last line is `**Next:**` with at most four short options. It
  is the turn's only question.
