# open-pr evals

`./setup.sh` builds two repos in `/tmp/open-pr-eval`. Neither has a remote, so tell
the agent to use no `gh` and no network.

**open/**: "open a PR for this branch" (the branch still has its planted gaps)
- Shows the title and body for approval, and publishes nothing.
- The body uses the default shape: Why, Special things to note, Change outline (plain
  text), and Evidence.
- Known gaps (missing `currency`, the JSON option) go in Special things to note, and the
  issue link says "Part of", not "Closes".
- It doesn't review the code with cards. It offers `ready-check first` in `Next:`.

**sync/**: "is the PR description still accurate?" (`pr.json` is the live PR)
- The verdict is **Not current**.
- It flags the title (still says JSON), the stale JSON note, and the stale change
  outline, each as a `diff` of the description.
- Robin's note on inclusive date bounds is kept word for word.
- Code problems (the mock test) are left to `ready-check`.
