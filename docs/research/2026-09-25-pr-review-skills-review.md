# PR review skills review (2026-09-25)

Scope: `receiving-review/`, `review-teammate-pr/`, `pr-review-format/`, and `evals/pr-review/` at commit `f6607c1`, reviewed as one diff on two separate axes, following the `code-review` method. **Standards** covers skill-authoring best practice. **Spec** covers the user's workflow requirements. The two axes are not merged or reranked. The Summary is the only place where recommendations from both appear together, ranked by impact.

Labels used below: **[Verified]** means checked against a primary source or by running it. **[Judgment]** means reasoned from sources but not measured. **[Open]** means the question could not be settled.

Sources were fetched on 2026-09-25 as Markdown:

- Anthropic best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Claude Code skills: https://code.claude.com/docs/en/skills
- Claude Code plugins reference: https://code.claude.com/docs/en/plugins-reference
- Agent Skills spec: https://agentskills.io/specification, plus the agentskills.io pages on best practices, optimizing descriptions, evaluating skills, and client implementation
- Codex skills: https://developers.openai.com/codex/skills
- GitHub REST and GraphQL docs, live GraphQL introspection, `gh` 2.101.0 help, and `gh` source
- The `vercel-labs/skills` CLI README and source (`src/installer.ts`, `src/agents.ts`)
- The user's guide: `~/.claude/skills/writing-for-agents/SKILL.md` and `SKILL-MECHANICS.md`

---

## 1. Summary: top recommended changes, ranked by impact

1. **Make the shared references install-safe.** Put the shared files in one plain folder that is not a skill, then symlink them into each skill's own `references/`. Link to them as `references/…` and delete the `pr-review-format` skill. Today, installing one skill alone silently breaks every link. See `receiving-review/SKILL.md:14-17`, `review-teammate-pr/SKILL.md:17-20`, `pr-review-format/SKILL.md:1-19` (§4).
2. **Keep the every-turn rules inside each SKILL.md.** The Turns bullets currently sit in a disclosed file that Claude Code does not re-attach after compaction, even though they govern every turn. See `pr-review-format/references/chat-format.md:35-52` (Standards S2).
3. **Fix the rules that contradict each other in receiving-review.** The Group column and the Finish table both break the "at most four columns" rule. The item-number scheme across rounds is also undefined. See `receiving-review/SKILL.md:124-126`, `:195`, `:104-105` and `chat-format.md:46-47` (Spec R1, R4).
4. **Close the loop gaps in receiving-review.** Three are missing: answered-but-unresolved threads (the eval expects an offer to resolve them), removing already-answered review-body findings from a new round, and the turn where a Defer issue gets approved. See `receiving-review/SKILL.md:100-105`, `:182-183`, `:88` and `evals/pr-review/README.md:65-66` (Spec R2, R3, R5).
5. **Use one invocation policy on both platforms.** Claude Code can auto-invoke both skills, while Codex turns implicit invocation off. See `receiving-review/SKILL.md:1-4`, `review-teammate-pr/SKILL.md:1-4`, and both `agents/openai.yaml:5-6` (Standards S4).
6. **Make the thread fetch paginate and read the latest comment reliably.** The skill says "paginate", but the query has no cursor, so it can't. See `pr-review-format/references/github.md:13-22` (§5).
7. **Upgrade the evals to the documented method.** Add a without-skill baseline, written assertions, trigger and near-miss queries, and real invocation instead of "read everything it links to". See `evals/pr-review/README.md:13-23` (Standards S9).
8. **Replace the literal "Claude Opus 5.5 · on behalf of Oliver" in 10 examples with placeholders or the rule.** The model name is time-sensitive, and a model running in Codex may copy it. See `receiving-review/references/reply-style.md:35-54`, `review-teammate-pr/references/comment-writing.md:27-54`, `receiving-review/SKILL.md:75,82` (Standards S7).

---

## 2. Standards findings

### S1. Cross-skill relative links fall outside the spec's file-reference model. Severity: High for public install, Low for the author's own machine

- **Where:** `receiving-review/SKILL.md:14-17,96,164`, `review-teammate-pr/SKILL.md:17-20,114,126`.
- **Source:** The Agent Skills spec says: "When referencing other files in your skill, use relative paths from the skill root" and "Keep file references one level deep from `SKILL.md`." (https://agentskills.io/specification#file-references). The client guide tells agents: "When a skill references relative paths, resolve them against the skill's directory (the parent of SKILL.md)" (https://agentskills.io/client-implementation/adding-skills-support). Neither addresses `../` paths into a sibling skill.
- **[Verified]** by running `bunx skills@latest add <this repo> --skill receiving-review -a claude-code -a codex -y` in a temp project. The install reported success with no warning, but `.claude/skills/receiving-review/../pr-review-format/references/chat-format.md` did not exist. With `--skill '*'`, all 8 cross-links resolved.
- **[Verified]** On the author's machine, both lexical and physical resolution of the link work, from `~/.claude/skills` and from `~/.agents/skills`.
- The fix is in §4.

### S2. Rules that apply to every turn sit in a disclosed file. Severity: Medium

- **Where:** `pr-review-format/references/chat-format.md:35-52`, reached through the pointer "Read these shared references before the first turn" at `receiving-review/SKILL.md:12` and `review-teammate-pr/SKILL.md:15`.
- **Source (Claude Code):** "When the conversation is summarized to free context, Claude Code re-attaches the most recent invocation of each skill after the summary, keeping the first 5,000 tokens of each." (https://code.claude.com/docs/en/skills#skill-content-lifecycle). That passage covers only the skill's rendered `SKILL.md`. It says nothing about reference files read with the Read tool.
- **Source (agentskills.io):** "Keep gotchas in `SKILL.md` where the agent reads them before encountering the situation. A separate reference file works if you tell the agent when to load it, but for non-obvious issues, the agent may not recognize the trigger." (https://agentskills.io/skill-creation/best-practices)
- **Source (user's guide):** "inline what every branch needs, and push behind a pointer what only some branches reach." (`writing-for-agents/SKILL.md`, Information hierarchy)
- **[Judgment]** Review sessions are long and multi-turn, which is where compaction happens. The Card and Turns rules are what every branch needs, so the user's own guide says they belong inline. `github.md`, `reply-style.md`, and `comment-writing.md` serve only some steps, so they are correctly disclosed.
- **Tradeoff:** Inlining roughly 18 lines into two SKILL.md files duplicates them. For the choice between duplicating and adding a re-read instruction, see §6.

### S3. `pr-review-format` is a skill used only as a file container. Severity: Low to Medium

- **Where:** `pr-review-format/SKILL.md:4,9-10`.
- With `disable-model-invocation: true`, Claude Code lists `/pr-review-format` in the menu. Its body is a table of contents that does nothing when invoked. Claude docs: "`disable-model-invocation: true`: Only you can invoke the skill." Codex also keeps it in the `$` picker ("explicit `$skill` invocation still works"). The CLI lists it as an installable skill as well (verified with `--list`).
- `disable-model-invocation` is not a spec field. "If you include any field the spec doesn't allow, packaging or upload fails with a hard error" for claude.ai uploads and the Skills API (https://code.claude.com/docs/en/skills#using-skill-frontmatter-outside-claude-code). **[Verified]** from the docs. Not exercised.
- The user's guide already names the better home: "Shared reference that two user-invoked skills both need can live in neither … Push it to a plain file outside the skill system." (`SKILL-MECHANICS.md:14`).

### S4. Invocation policy differs between Claude Code and Codex. Severity: Medium

- **Where:** Neither SKILL.md frontmatter sets `disable-model-invocation`, so Claude can auto-load both skills. Both `agents/openai.yaml:5-6` set `allow_implicit_invocation: false`, so Codex will not.
- **Sources:**
  - Claude docs: "Use this for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`."
  - Codex docs: "`allow_implicit_invocation` (default: `true`): When `false`, Codex won't implicitly invoke the skill based on user prompt."
  - User's guide: "If it only ever fires by hand, make it user-invoked and pay no context load." (`SKILL-MECHANICS.md:12`)
- **[Judgment]** Pick one policy. The evals only test explicit invocation ("when the user invokes `/<skill>`", `evals/pr-review/README.md:16`). If manual invocation is the real use:
  - add `disable-model-invocation: true`, and
  - shorten each description to a one-line human summary, as `SKILL-MECHANICS.md:10` says.

  If auto-triggering is wanted, set Codex's `allow_implicit_invocation` back to true and add trigger evals (S9).

### S5. Descriptions. Severity: Low

- **Sources:**
  - "Include both what the Skill does and specific triggers/contexts" and "Always write in third person" (Anthropic).
  - "Focus on user intent, not implementation" and use near-miss negatives (https://agentskills.io/skill-creation/optimizing-descriptions).
  - "Front-load the key use case and trigger words" (Codex).
  - "One trigger per branch" (user's guide).
- **What works:** Both descriptions are third person, front-loaded, 259 to 298 characters, and route near-misses to the sibling skill. **[Verified]**
- **Gaps in `receiving-review/SKILL.md:3`:**
  - "fixes, commits, pushes" advertises an automatic push, but the body limits pushing to "Push only when the user says so" (`:168`).
  - The "new round of comments" branch (`:104-105`) has no trigger in the description.
  - The description routes to `code-review`, a skill this repo doesn't ship.
- **Gap in `review-teammate-pr/SKILL.md:3`:** It spends words on mechanics ("discusses findings in chat, then drafts and posts").
- If S4 goes the manual-invocation route, most of this becomes moot.
- **Update: uncommitted working-tree edits made during this review.** All three descriptions changed:
  - `receiving-review` now reads "Handles review comments on your own PR or stack: verify, fix, reply, resolve. For someone else's PR, use review-teammate-pr." The "pushes" and `code-review` problems are gone.
  - It also dropped the "Use when … (cubic, CodeRabbit)" trigger clause. Anthropic asks for "both what the Skill does and when to use it".
  - `review-teammate-pr` now says "with you … you approve". Anthropic warns against second-person point of view: "Avoid: 'You can use this to process Excel files'".
  - `pr-review-format` now reads "Shared format and rules for the PR review skills."
  - These shorter, human-facing descriptions fit a manual-invocation choice under S4. With model invocation still on in Claude Code, they now carry fewer triggers.

### S6. Undeclared external skill dependencies. Severity: Low

- **Where:** `review-teammate-pr/SKILL.md:69-70,75-77` (the `code-review` smell baseline and sub-agents) and `chat-format.md:24` (a `show-me` skill). Neither ships in this public repo.
- Anthropic's guidance on dependencies ("Don't assume packages are available") applies by analogy, and the spec offers `compatibility` for environment requirements (for example, "Requires git, docker, jq…").
- **[Judgment]** Either state the smell list inline in a few words or mark it "if installed". Add `compatibility: Requires git, gh (authenticated), jq` to both workflow skills.

### S7. Time-sensitive, overfitting examples. Severity: Medium

- **Where:** "Claude Opus 5.5" and "Oliver" appear in 10 disclosure lines across `receiving-review/SKILL.md` (2), `reply-style.md` (4), and `comment-writing.md` (4). `disclosure.md:9-10` also names "Claude Opus 5.5" and "GPT-5.6 Sol".
- **Source:** "Don't include information that will become outdated" (Anthropic, Avoid time-sensitive information). agentskills.io also warns against narrow patches: "Fixes should address underlying issues broadly".
- **[Judgment]** When 10 examples all carry the same literal, a model running in Codex is likely to copy "Claude Opus 5.5". Use `{model}` and `{name}` in the examples, and keep the real values only in `disclosure.md`.
- The example code is also tied to one stack (Effect/Prisma `upsert`, `CurrentCompany`, `Layer.mock`). That is fine as illustration, but it is not neutral.

### S8. Duplication and no-ops. Severity: Low

Duplicated meanings (the user's guide asks for a "single source of truth"):

- "Read before retrying so each write lands once" appears at `receiving-review/SKILL.md:187-188` and `github.md:90-91`.
- "Show only code the user hasn't seen; list tests as one-line cases" appears at `receiving-review/SKILL.md:154-155` and `chat-format.md:40-41`.
- "Give the outcome and the one reason that matters" (`reply-style.md:12`) repeats "Lead with the outcome" (`:6`) and "One to three sentences" (`:3-4`).

Likely no-ops (test: "does it change behaviour versus the default?"):

- `comment-writing.md:21` "Colleague tone. State the issue and the ask." This repeats `:6`.
- The synonym list at `receiving-review/SKILL.md:147` ("yes", "go for it", "fix it", "do it") could become "an affirmative reply to a proposal authorizes it".

Ambiguity:

- `comment-writing.md:12` "Most comments are optional." conflicts with keeping only findings "with a concrete consequence" (`review-teammate-pr/SKILL.md:82`). A model may label verified bugs `Non-blocking:`.

Negation (the guide asks for positive phrasing): The skills mostly phrase rules positively. "Approving, requesting changes, and merging stay with the user" (`review-teammate-pr/SKILL.md:132`) is a good example. There was no significant negation to fix. **[Verified]** by reading.

### S9. Evals miss key parts of the documented method. Severity: Medium

**What the docs ask for:**

- "Measure Claude's performance without the Skill" and build "three scenarios" (Anthropic, Build evaluations first).
- "run each one in a fresh session with the skill available and again with it disabled" (Claude Code, Evaluate and iterate).
- Prompts plus expected outputs, then assertions graded PASS or FAIL "with specific evidence", stored as `evals/evals.json`. Trigger testing uses about 20 should-trigger and should-not-trigger queries with near-misses (agentskills.io evaluating and optimizing pages).
- "Missed connections: Does Claude fail to follow references to important files?" (Anthropic, Observe how Claude navigates Skills).

**What the evals already do well:** three scenarios, a fresh session, at least two models (`README.md:13,23`), and realistic fixtures with no internal names.

**Gaps:**

- No without-skill baseline.
- Expectations are prose, with no graded assertions file and no recorded results.
- No trigger or near-miss queries, for example "review my own diff" should route away.
- The prompt says "Read the skill's `SKILL.md` and everything it links to" and "Act as the main agent would". That forces full reading and bypasses real invocation, so it cannot detect missed pointers (S2) or broken `../` links (S1).
- No scenario covers:
  - review-body findings in a new round
  - a stack
  - the head moving before posting
  - an existing pending review
  - the edit-N path
- `setup.sh:6` runs `rm -rf "$out"` on a user-supplied path. **[Judgment]** Guard it so it only deletes paths under `/tmp`.

### S10. Items that meet the docs. [Verified]

- **Frontmatter:** Names match their directories and follow the spec's character rules. Descriptions are under 1,024 characters.
- **Size:** `SKILL.md` bodies are 197 and 148 lines (1,316 and 954 words), under the 500-line guidance.
- **Nesting:** All references are one level deep. No reference file exceeds 100 lines.
- **Commands:** The GitHub commands are exact, which is right for a "narrow bridge" operation (Anthropic, degrees of freedom).
- **Completion criteria:** Every step has a "Done when" criterion except receiving-review §5 (Spec R6).
- **Codex metadata:** `openai.yaml` uses only documented fields: `interface.display_name`, `short_description`, `default_prompt`, and `policy.allow_implicit_invocation`.

Naming note: the three names mix a gerund (`receiving-review`), an action (`review-teammate-pr`), and a noun phrase (`pr-review-format`). Anthropic lists "Inconsistent patterns within your skill collection" under Avoid. Low priority.

---

## 3. Spec findings

Each requirement below is marked **Delivered**, **Partial**, or **Gap**.

### Shared chat format

| Requirement | Where | Status |
|---|---|---|
| A card has a one-line summary, status line, 🔎 Grounded line, picture when needed, and code in context | `chat-format.md:11-29` | Delivered. The card also adds a Location line. |
| Bullets are one line; each thing is said once; one FYI line | `chat-format.md:28,39-49` | Delivered |
| Exactly one bold `Next:` line, which is the turn's only question | `chat-format.md:51-52` | Delivered |
| One decision per turn, except the documented batch paths | `chat-format.md:50` | Partial: see R1 and T1 |
| Grounded, not answered from memory | `grounding.md:3-13` | Delivered, with a stated exception for trivial fixes (`chat-format.md:20-21`). Table rows with no card (small fixes) show no status or grounding until after the fix. Consider a ✅ or ⚠️ glyph in the Call cell. |

**C1. Pictures may not render.** `chat-format.md:23` asks for "a sequence diagram (Mermaid)". In a terminal client, Mermaid appears as source text, which works against a visual, scanning user. **[Open]** It depends on which client renders the chat. ASCII call trees, as in the examples, always render.

**C2. The heading slot means different things in each skill.** In `chat-format.md:13`, the slot is `<call>`. The receiving example uses a call ("Fix"), but the teammate example uses a finding type ("Bug", `review-teammate-pr/SKILL.md:25`). Name the slot `<kind>`, or define it per skill.

### receiving-review

| Requirement | Where | Status |
|---|---|---|
| Stable item numbers | `:112-113` | Partial: see R4 |
| Narrow triage table | `:24-28,124-126` | **Gap:** see R1 |
| "All as recommended" one-answer path | `:138-140` | Delivered. It doesn't say whether the answer covers the clear items when some items still need a decision. |
| Flow-changing fixes shown as cards before they are applied | `:128-133,142-143` | Delivered |
| Tests listed as one-line cases | `:72,155` | Delivered |
| Commit, push, reply, and resolve offered as one question; push only when asked | `:165-170` | Delivered. The description contradicts it (S5). |
| Approving drafts means posting them | `:173-174` | Delivered |
| `AGENT {model} · on behalf of {name}` disclosure | `:163-164`, `disclosure.md` | Delivered |
| Resolve defaults | `:176-184` | Partial: see R3 |
| CodeRabbit findings in review bodies | `:97-99,102`, `github.md:44-50` | Partial: see R2 |
| Every step ends in "Done when" | `:107,142,157,190` | **Gap:** §5 Finish (`:193-197`) has none. See R6. |

**R1. Tables are wider than the rule allows.** `chat-format.md:46` says "Use at most four columns". The triage table with a Group column (`:124-126`) has five: #, Who·where, Claim, Call, Group. The Finish table (`:195`: item, outcome, commit, reply, thread state) also has five. Suggested fix:

- Mark a group with a letter prefix in the `#` cell, for example `A1`, `A2`.
- Merge the reply and thread-state columns in the Finish table.

**R2. On a new round, already-answered review-body findings come back.** Threads are filtered with the rule that the latest comment is ours (`:100-102`). Review-body findings get PR comments (`github.md:46`), which that rule can't detect. So each new round re-lists old CodeRabbit body findings. Eval 03 misses this because it has `"reviews": []`. One fix: fetch the conversation comments with the agent disclosure and skip findings those comments already quote.

**R3. Answered but unresolved threads.** The eval expects the agent to mention that PRRT_1 and PRRT_5 "are answered but still open, and offers to resolve them" (`evals/pr-review/README.md:65-66`). The skill drops those threads at fetch time (`:101-102`), and no instruction brings them back.

The resolve rules are also inconsistent:

- A human Decline is left open (`:180-181`).
- A No-change item is resolved regardless of who raised it (`:184`).

Suggested fix: add "List answered-but-open threads on one line and apply the resolve defaults to them", and state who resolves in the No-change case.

**R4. Numbering across rounds is undefined.** `:104-105` lists only new or changed items, but doesn't say whether numbering continues from the last round or restarts. The user refers to items by number (`:113`), so a restart makes "do 2" ambiguous. State "continue numbering from the previous round".

**R5. The Defer approval has no turn.** A Defer needs issue approval ("Create it once approved", `:182-183`). The closing `Next:` options (`:88`, `:165-166`) don't include that approval. The same example message also offers replies, so a Defer adds a second pending decision. Either add "create follow-ups" to the loop question, or ask for the Defer decision during triage.

**R6. §5 Finish has no completion criterion.** Suggested: "**Done when:** every item has an outcome row, and every open thread, unpushed commit, and follow-up is listed."

### review-teammate-pr

| Requirement | Where | Status |
|---|---|---|
| Short findings list with a verdict and a "Dropped N: reasons" line | `:90-97` | Delivered |
| Decisions via lock / drop / ask as question / merge | `:103-104`, `:47` | Partial: see T2 |
| Drafts shown together as blockquotes once every finding is decided | `:112-117` | Delivered |
| Approving means posting as one COMMENT review | `:119-120,130-131` | Delivered |
| The agent never approves the PR | `:132` | Delivered, phrased positively |
| Re-review ends with a verdict | `:147-148` | Delivered. It doesn't say whether new findings loop back to §3 and §4. |

**T1. The findings-list turn has no `Next:` line.** §3 opens with the list (`:90-97`), then says "Then go through the findings one at a time … one card per turn" (`:102`). It's unclear whether the list turn also carries card 1, and what that turn's `Next:` is. Suggested fix: "The list turn also shows card 1 and ends with that card's `Next:`."

**T2. The decision words differ across the skill.**

| Place | Words used |
|---|---|
| Example card `Next:` (`:47`) | lock · drop · ask as question · optional (no merge) |
| Body (`:103-104`) | "lock as optional suggestion" |
| Done when (`:108`) | locked, dropped, or merged (no ask-as-question state) |

Anthropic: "Choose one term and use it throughout the Skill." Suggested set: lock · optional · question · drop · merge into N.

**T3. The skill depends on an external `code-review` skill** (`:69-70,75`). See S6.

---

## 4. Structure and portability

**What the docs say about a sibling skill linked with `../`**

- **Agent Skills spec:** References are "relative paths from the skill root" in "your skill". Cross-skill references are not covered. **[Verified]**
- **Claude Code standalone skills:** Silent on cross-skill links. Symlinked skill folders are supported: "a `<skill-name>` entry … can be a symlink to a directory elsewhere on disk." **[Verified]**
- **Claude Code plugins:** Shared files between skills are a documented feature. `${CLAUDE_PLUGIN_ROOT}` is for "resources shared between the plugin's skills". Paths outside the plugin root are rejected ("path escapes plugin directory"). Symlinks within a marketplace are dereferenced into the cache. Sibling skills under one plugin's `skills/` stay inside the root. **[Verified]**
- **Codex:** "Codex supports symlinked skill folders and follows the symlink target." Plugins can "bundle two or more skills together", but the docs don't say how bundled skills share files. **[Verified]** that the docs are silent on this.
- **`npx skills add`:**
  - Each skill is copied into a canonical `.agents/skills/<name>`, and agent directories are symlinked to it.
  - Siblings resolve only when both are installed in the same scope.
  - Installing a subset gives no warning and breaks the links.
  - The README documents no dependency mechanism.
  - **[Verified]** by the temp-project runs in S1 and by `src/installer.ts`.

**Current arrangement**

- **It works:** in the author's symlinked setup, and in a full `--skill '*'` install in one scope.
- **It breaks:**
  - when installing a subset
  - when skills are split across project and global scope
  - on claude.ai or Skills API upload, since the frontmatter field fails validation (S3)

**Better-supported arrangement.** **[Verified]** for a local source; **[Judgment]** for a remote source.

1. Move the four shared files to a plain folder that is not a skill, for example `shared/pr-review/`. This follows the user's guide on plain files outside the skill system (`SKILL-MECHANICS.md:14`).
2. In each workflow skill, add file symlinks such as `references/chat-format.md -> ../../shared/pr-review/chat-format.md`. Link to them as `references/chat-format.md`, which follows the spec and stays one level deep.
3. Delete the `pr-review-format` skill.

**Evidence:**

- In a temp repo, a skill whose `references/chat-format.md` was a relative file symlink installed with `bunx skills add` as a real file with the shared content. The cause is `copyDirectory` in `src/installer.ts`, which uses `cp(..., { dereference: true })`, with the comment "tells Node to copy the file instead of copying the symlink".
- The author's symlinked dev setup resolves the file symlinks at read time.

**Result:** one source of truth in the repo, and each installed skill is self-contained.

**Caveats:**

- A remote GitHub install was not tested. It uses the same copy path after cloning.
- Git on Windows needs `core.symlinks`.

**Alternatives:**

- **A Claude Code plugin with the three skills under `skills/`.** Documented for sharing, but Claude-only packaging.
- **Merging the two workflows into one skill with a shared inline format and per-workflow references.** This fixes S2 cleanly. It loses the two separate slash commands and the per-workflow descriptions. The user's guide says to split only for "a distinct leading word that should trigger it on its own". Here there are two distinct triggers (own PR vs. teammate PR), so keeping two skills is defensible.

---

## 5. Verified GitHub commands

All checks were read-only. Live GraphQL introspection and the `pr view`/`checks` commands ran against the public PR `cli/cli#14507`.

| Command (`github.md`) | Verdict | Evidence |
|---|---|---|
| Review-thread GraphQL query (`:13-18`) | **Correct.** Ran as written. | Introspection confirms `PullRequestReviewThread.{id,isResolved,isOutdated,path,line,originalLine,comments}` and `PullRequestReviewComment.fullDatabaseId: BigInt`, which is returned as a JSON string. `databaseId` is deprecated because it "does not support 64-bit signed integer identifiers. Use `fullDatabaseId` instead." |
| `-f owner -f repo -F number` (`:13`) | **Correct** | `gh api --help`: "For GraphQL requests, all fields other than `query` and `operationName` are interpreted as GraphQL variables". `-F` converts integers. |
| "Paginate before drawing conclusions" (`:22`) | **Not actionable as written** | `gh api --help`: GraphQL `--paginate` "requires that the original query accepts an `$endCursor: String` variable and that it fetches the `pageInfo{ hasNextPage, endCursor }`". The query has neither, and nested `comments` can't be paginated this way. Add `pageInfo`/`$endCursor` for threads, and fetch `comments(last:1)` for the latest-comment check. |
| First comment `fullDatabaseId` is the reply target (`:25`) | **Correct** | REST: "This must be the ID of a top-level review comment, not a reply to that comment. Replies to replies are not supported." (https://docs.github.com/en/rest/pulls/comments#create-a-reply-for-a-review-comment) |
| `gh pr view N --json reviews,comments --jq …` (`:32-33`) | **Correct.** Ran as written. | Review objects contain `author, authorAssociation, body, commit, id, …, state, submittedAt` and no `url`. The card rule "quotes the reviewer's comment with its link" (`receiving-review/SKILL.md:135`) has no URL to use for review-body findings. |
| `gh pr checks N` (`:34`) | **Correct**, with a caveat | `gh pr checks --help` lists "Additional exit codes: 8: Checks pending". Failures exit non-zero (`gh help exit-codes`). The agent should not read a non-zero exit as a command error. |
| `POST repos/O/R/pulls/N/comments/ID/replies -F body=@reply.md` (`:40-41`) | **Correct** | REST endpoint and required `body` confirmed at the link above. `-F` with `@file` reads the file as a string: `magicFieldValue` returns `string(b)` (`cli/cli` `pkg/cmd/api/fields.go`). |
| `gh pr comment N --body-file reply.md` (`:50`) | **Correct** | `gh pr comment --help`: "-F, --body-file file  Read body text from file". |
| `resolveReviewThread(input:{threadId})` → `thread{isResolved}` (`:56-57`) | **Correct** | Introspection: `ResolveReviewThreadInput.threadId: ID!`; the payload has `thread`. (https://docs.github.com/en/graphql/reference/mutations#resolvereviewthread) |
| Create a pending review: `--input review.json` with `commit_id` and `comments[{path,line,side,body}]` and no `event` (`:63-71`) | **Correct** | REST: "To create a pending review for a pull request, leave the event parameter blank." `comments[]` accepts `path` (required), `body` (required), `line`, `side`, `start_line`, `start_side`. `gh api --help`: "a request body may be read from file specified by `--input`". (https://docs.github.com/en/rest/pulls/reviews#create-a-review-for-a-pull-request) |
| Submit with `POST …/reviews/ID/events -f event=COMMENT` and no body (`:72,78-79`) | **Correct per the docs.** Not live-tested, since it is a write. | Submit endpoint: `event` is required and `body` is optional ("The body text of the pull request review"). On *create*, `body` is "Required when using REQUEST_CHANGES or COMMENT", which is why the two-step flow is needed. (https://docs.github.com/en/rest/pulls/reviews#submit-a-review-for-a-pull-request) |
| "`line` is the line in the head file" (`:75`) | **Partly correct** | REST describes `line` as "The line of the blob in the pull request diff". "Head file" is right only for `side: RIGHT`. With `LEFT` (deletions), the blob is the base version. Suggested wording: "the line in the file on that `side`". The rule "must fall inside a diff hunk" is not stated on these pages. **[Open]** |
| `side` RIGHT or LEFT; `start_line` + `start_side` for ranges (`:76-77`) | **Correct** | "Use LEFT for deletions that appear in red. Use RIGHT for additions … or unchanged lines"; `start_line`/`start_side` are "Required when using multi-line comments". |
| "GitHub allows one pending review per user" (`:80`) | **Unverified** | Not stated on the REST reviews or comments pages. A "Delete a pending review" endpoint exists (`DELETE …/reviews/{review_id}`) and could be offered as an option. |
| Verify with `GET …/reviews/ID/comments --jq '{path, line, html_url}'` (`:87`) | **Correct** | The response schema includes `path`, `line`, and `html_url`. |
| `jq --rawfile` (`:63`) | **Correct** | `jq --help` (1.8.2): "set $name to string contents of file". |

---

## 6. Open questions and what I could not verify

- **Codex skill-to-skill invocation.** `grounding.md:9` says "run `grounding`", but `grounding/agents/openai.yaml` sets `allow_implicit_invocation: false`. The Codex docs only say explicit `$skill` still works. They don't say whether one skill's instructions can load another skill that has implicit invocation off. Claude Code is fine, since `grounding` has no `disable-model-invocation`.
- **Compaction.** Whether Claude Code or Codex keep reference-file content after compaction. Claude docs describe re-attaching `SKILL.md` only. Codex docs don't cover it. **Decision for the user:** inline the Turns rules into both SKILL.md files (duplication), or keep one source and add a line such as "Re-read `references/chat-format.md` after context is summarized". The second option depends on the model noticing that compaction happened.
- **Pure file-container skill.** Whether Claude Code accepts `disable-model-invocation: true` together with `user-invocable: false`. The docs' table covers each flag alone, not both.
- **Remote install.** The `npx skills add` symlink-dereference behavior was tested with a local source only, not a GitHub source.
- **Pending-review rules.** Whether one pending review per user and the in-hunk rule for `line` are documented anywhere on docs.github.com. I didn't find either on the REST pages I read.
- **Submitting COMMENT with no body.** The `/events` call is documented as valid, but not tested live because that is a write.
- **Mermaid rendering.** Whether the user's chat client renders Mermaid (C1).
- **Codex global path.** The skills CLI installs Codex global skills to `$CODEX_HOME/skills` (`src/agents.ts`), while the Codex docs list `$HOME/.agents/skills` as the user location. This doesn't affect the author's setup, which uses `~/.agents/skills` directly. It may matter for other users running `-g -a codex`.
- **Not run.** None of the three eval scenarios were run against the skills, and no with-skill or without-skill comparison was made. The spec findings come from reading the text, not from observed runs.
