---
name: grounding
description: Verifies a technical claim or decision against installed code, primary docs, and project rules before it is relied on. Use when asked whether something is idiomatic, correct, or best practice, when asked "are you sure?", or to verify a recommendation.
---

# Grounding

Check one claim against real evidence before anyone relies on it: the installed code,
the library's own docs and source, and the project's rules. Grounding establishes
what's true. Project instructions and convention skills still decide what to do with
it.

From the request and the context, name the claim, the target (a package, a tool, or a
design question), and the environment. Ask only when a missing decision would change
the investigation, and keep gathering evidence in the meantime.

## Sources

Check every row that applies:

| Target | Check |
|---|---|
| Package or library | Which workspace owns the import. The locked, installed version, and its type declarations or source in `node_modules`. Peer packages only when they interact. For an uninstalled package, read the source at the exact version tag and say it isn't installed. |
| Tool or platform | The installed or live version and local config. The tool's `--help`, source, or current official docs. Live state when deployed behavior matters. |
| Design or architecture | The project's docs, ADRs, and domain rules, plus the relevant spec or standard. Add a minimal reproduction when the docs don't settle it. |

When a docs MCP server for the library is connected (for example effect-docs or
context7), use it alongside the installed source. If the two disagree about the
installed version, the installed source wins.

### Idiomatic and best-practice claims

"Idiomatic" means the way the library's authors intend it to be used. Rank the evidence
in this order:

1. The library's official docs, guides, and examples.
2. The library's own source, tests, and maintained example repos, at the installed
   version.
3. The project's rules: its conventions and ADRs.
4. Repo precedent. This shows consistency, not idiom.

When repo precedent and the library's idiom disagree, show both and say which one the
project's rules favor. To claim one option is best, name the project's constraints and
compare the viable alternatives against them. A comparison, or a claim that no
alternative exists, states the search scope and the date.

## Depth

Keep reading until more reading wouldn't change the decision. Widen the search when
sources conflict or leave a material gap.

- **Uncertain API combinations or runtime behavior**: run a minimal example against
  the installed version before calling it working. Label an untested sketch
  `Proposal`.
- **Experiments**: resolve uncertainty with reversible local experiments. Pause only
  the work whose remaining ambiguity touches user intent, security, external effects,
  or a public contract.
- **Delegation**: hand off a bounded question only when independent expertise helps
  and delegation is authorized.
- **Open details**: an unresolved implementation detail stays an open question. Keep
  it separate from the verdict on the design.

## Result

Lead with the answer, then what to do, then the evidence:

````markdown
**Partly.** `configVersion: 1` is valid, but `0` matches how this repo's lockfile was created.

```diff
- "configVersion": 1
+ "configVersion": 0
```

✅ Verified: clean install succeeds with both values
🔎 Sources: `bun.lock` header · Bun docs on lockfile config
⚠️ Unverified: whether CI caches are keyed on the lockfile
````

- **Verdict first.** The first word is **Yes**, **No**, **Partly**, or **Unclear**. For
  a choice between options, the first words name the pick.
- **The change next.** Show a `diff` or code shape, or write "No change".
- **Evidence lines.** One line each for verified, sources, and unverified. Leave out any
  line that would be empty.
- **Picture.** Add one, such as a call tree or flow, when the flow is the point.

## Challenges and re-checks

A challenge ("are you sure?", "nothing else?", "is that idiomatic?") asks for a
re-check.

- Re-check the claim against the sources. If it holds, say so and list what was checked.
- Change a conclusion only on new evidence, and name that evidence:
  `Changed: <old> → <new>, because <evidence>`.
- Asked for more findings, report what the re-check turns up. "Nothing further", with
  the scope checked, is a complete answer.

## Reuse

Reuse verified evidence while the target, the version, the rules, and the relevant
state stay unchanged. Explaining, implementing an accepted decision, drafting comments,
and a final review all reuse it. Recheck only what new code, new state, or conflicting
evidence invalidates, and state a changed conclusion in one line.

**Done when:** the answer gives a verdict, the evidence it rests on, and anything still
unverified.

Read [references/evaluation.md](references/evaluation.md) only when the user asks to
evaluate this skill.
