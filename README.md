# Claude Code

## What the installer does

Replaces `~/.claude/CLAUDE.md`, `rules/`, `stacks/`, `hooks/`, every skill and agent that exists in this repo, and the `permissions.allow`, `permissions.ask`, `permissions.deny`, and `hooks` keys of `~/.claude/settings.json`, and enables the plugins listed under `enabledPlugins`. Everything else in `~/.claude/` is untouched: `context/`, `worklogs/`, `docs/`, synced and hand-made skills and agents, `projects/`, credentials, and every other settings key, including `permissions.additionalDirectories`. Backs up the owned paths to `~/.claude-setup-backups/` and keeps the last 5. Safe on a fresh machine and on one with an existing setup. Edit this repo, rerun; never hand-edit the owned paths.

## Install on any machine

Requires Claude Code (run once so `~/.claude/` exists) and `jq`.

```bash
git clone <this repo> ~/dev/claude-setup
cd ~/dev/claude-setup
bash install.sh
```

Rerun after every pull or edit.

## What loads when

- `CLAUDE.md`: every session, every machine. Judgement rules only, under 100 lines.
- `rules/*.md`: when Claude touches a matching file (`paths` in the frontmatter). JavaScript and TypeScript, TypeScript types, React, tests, accessibility.
- `stacks/*.md`: at session start, chosen from `package.json` dependencies, because a `.tsx` screen and a `.tsx` web component look the same. React Native, Next.js, NestJS, TanStack. In a monorepo every workspace's dependencies count, so a repo with a web app and a mobile app loads both.
- `hooks/`: deterministic. Format and lint every edit, snapshot the repo at each prompt, and when the turn ends lint, format, and typecheck everything the turn changed by any tool and hold it to a budget of 150 changed lines and fewer than 3 new files (over it, the turn cannot end until every addition is deleted or justified). Block env files, lockfiles, and settings files, prompt before migrations and writes outside the working directories, inject the repo context at start.
- Skills with `disable-model-invocation: true` cost nothing until you type them.

## Writing outside the current repo

A write outside the current repo prompts you, with the path and the reason, in every permission mode including auto. Approve it once and it happens. To stop the prompts:

- This session: `/add-dir /path/to/other-repo`.
- Every session on this machine: add the path to `permissions.additionalDirectories` in `~/.claude/settings.json`. The installer preserves it.

```bash
jq '.permissions.additionalDirectories = ["/path/to/bff", "/path/to/obsidian/handoffs"]' \
  ~/.claude/settings.json > /tmp/s && mv /tmp/s ~/.claude/settings.json
```

Env files, lockfiles, anything under `.git/`, and Claude Code settings files stay blocked everywhere; you edit those by hand. A migration prompts, so approve it only when you asked for one. The installed setup under `~/.claude` prompts with a warning that the next `bash install.sh` overwrites it: it changes here, then `bash install.sh`. Destructive commands (`rm -rf`, `git reset --hard`, `git clean`, `git rebase`, and the like) prompt before they run.

## A repo that already has a `.claude` folder

`git ls-files .claude` shows the team's files, leave them; they load alongside yours and `/map` reads a repo `CLAUDE.md` rather than repeating it. Untracked `settings.local.json` is only past "don't ask again" answers, safe to delete. If a repo `CLAUDE.md` has the same rules I do, delete my lines.

## Verify

In a TypeScript repo, run `claude`:

- `/context`: `~/.claude/CLAUDE.md` listed; no rule files yet.
- Have Claude read a `.tsx`; `/context` again: the javascript, typescript, react, and accessibility rules are listed.
- `/hooks`: SessionStart (two), UserPromptSubmit, PreToolUse (two), PostToolUse, Stop, SessionEnd, DirectoryAdded under User settings. `/permissions`: allow and ask lists.
- `/` shows `ac`, `audit`, `continue`, `council`, `debug`, `design`, `design-doc`, `explain`, `handoff`, `log`, `map`, `note`, `pr`, `research`, `review`.
- Ask for an unused variable in a `.ts` file: Claude receives the lint output and removes it.
- Ask for a string assigned to a number: ending the turn surfaces the `tsc` error.
- Ask Claude to edit a file in another repo: a permission prompt names the path and `/add-dir`.
- Ask for a change that is plainly more than 150 lines, or ask for three new files: ending the turn surfaces the budget message and Claude deletes or justifies each addition before it stops.
- `/doctor prompt-audit`: no contradictions between `CLAUDE.md`, rules, skills, and agents.

## First session in any repo

```
/map
```

or with facts Claude cannot find:

```
/map backend is /path/to/bff; never call the services behind it directly
```

Read the file it shows. Fix anything wrong with `/note` or by editing `~/.claude/context/<repo>.md` directly; the installer never touches it. From the next session on, it is injected at start.

## Daily use

**Any task.** Type it. Claude plans first when the change spans files or the approach is uncertain, and skips the plan when the diff fits in one sentence. Force plan mode with `Shift+Tab`. Edits trigger the format and lint hook silently; ending a turn triggers typecheck if code changed.

**A ticket.** `/ac ABC-123 ticket:` then paste the criteria on the same line, then Enter. Claude reads what the AC touches, lists `TODO`s, batches questions with defaults, gives a phased plan, stops. Approve. After each phase: hooks clean, existing tests run, evidence, one commit message ending in `(ABC-123)`, you review the diff, "next phase" or corrections. Claude never commits.

**Review.** `/review` reviews every file changed since the default branch (origin's `HEAD`, else `main`, `master`, or `develop`) plus uncommitted changes, like a PR review: defects only, over-engineering included, each one verified against the code, at most ten. `No findings.` is the normal result for sound work. Approve by number; it applies only those. The bundled `/code-review` is a free second opinion; only `/code-review ultra` costs money. The bundled `/simplify` hunts for reuse and may extract shared code; the deletion pass is `/review`.

**Stopping for the day mid-plan.** `/continue ~/Obsidian/handoffs/ABC-123.md`. It writes a document with the task, the plan with each phase's status, decisions, what is verified, and the exact next action. Next session, in the same repo: `/ac` and paste the document. It starts at the next action with no questions. The folder must be writable: `/add-dir` it, or put it in `additionalDirectories`.

**A change that needs other repos.** `/handoff`. From the AC and the plan it already knows which repos must change and what each must provide; it reads each target through `explorer`, fills a verified contract, and prints one handoff per repo. Open a session in each repo and paste its handoff into `/ac`. Own plan, own review, own commit messages. Code against a contract only after it landed.

**A bug, no ticket.** `/debug <symptom, trace, file>`. Reproduce, hypothesis, one change, root cause, verify, commit message.

**Pointing at files.** Once: `@path` in the message. Every session in this repo: `/note` a pointer, never the content. Still point at things Claude cannot discover (tickets, specs, meeting decisions); the goal is never to point twice.

**Something worth keeping.** `/note it` (repo fact), or edit this repo and rerun the installer. A new house convention for JavaScript or TypeScript goes under `## Conventions` in `rules/javascript.md`.

**End of session.** `/log`, or `/log <focus>`. Nothing is logged otherwise. The last entry is injected at the next session start.
