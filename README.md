# Claude Code

## What the installer does

Deletes and rebuilds `~/.claude/CLAUDE.md`, `rules/`, `hooks/`, `skills/`, and the `permissions.allow`, `permissions.ask`, and `hooks` keys of `~/.claude/settings.json`. Everything else in `~/.claude/` is untouched: `context/`, `worklogs/`, `projects/`, credentials, and every other settings key, including `permissions.additionalDirectories`. It backs up the whole folder first, every run. Edit this repo, rerun; never hand-edit the owned paths.

## Install on any machine

Requires Claude Code (*run once so `~/.claude/` exists*) and `jq`.

```bash
git clone <this repo> ~/dev/claude-setup
cd ~/dev/claude-setup
bash install.sh
```

Rerun after every pull or edit.

## Access to sibling repos
(*e.g., a work machine with a BFF and services next to the app*)

This is machine state, not setup. Add the paths once, on that machine, and the installer preserves them:

```bash
jq '.permissions.additionalDirectories = ["/path/to/bff", "/path/to/service-one", "/path/to/service-two"]' \
  ~/.claude/settings.json > /tmp/s && mv /tmp/s ~/.claude/settings.json
```

Or answer the prompt when Claude first reads outside the repo. Nothing breaks without it. Absolute paths never enter this repo, which is why it can be public.

## A repo that already has a `.claude` folder

`git ls-files .claude` shows the team's files, leave them; they load alongside yours and `/map` reads a repo `CLAUDE.md` rather than repeating it.

Untracked `settings.local.json` is only past "don't ask again" answers, safe to delete.

If a repo `CLAUDE.md` has the same rules I do, delete my lines.

## Verify

In a TypeScript repo, run `claude`:

- `/context`: `~/.claude/CLAUDE.md` listed with a token count; the rule files not yet.
- Have Claude read a `.tsx`; `/context` again: both rule files listed. If they werelisted before any file was touched, see section 10 item 1.
- `/hooks`: four hooks under User settings. `/permissions`: allow and ask lists.
- `/` shows `ac`, `log`, `map`, `note`.
- Ask for an unused variable in a `.ts` file: Claude receives eslint output, removes it.
- Ask for a string assigned to a number: ending the turn surfaces the `tsc` error.
- Ask Claude to edit a file in another repo: blocked with a message.

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

**Any task.** Type it. `CLAUDE.md` makes Claude plan first for non-trivial work. Force plan mode with `Shift+Tab`. Edits trigger the lint hook silently; ending a turn triggers typecheck if code changed.

**A ticket.** `/ac ` then paste the criteria on the same line, then Enter. Claude reads what the AC touches, lists `TODO`s, batches questions, gives a phased plan, stops. Approve. After each phase: commit message, you review the diff, "next phase" or corrections. Claude never commits.

**A change that spans two repos.** One session per repo; the handoff is a paragraph in Claude's reply, not a file. `/ac` writes it when it finds the other repo lacks what the AC needs. Check out a branch in that repo, open a session there, paste the handoff into `/ac`. Own plan, own review, own commit message, own hooks. If the handoff will wait until a future session, `/log` captures it under `Open`.

**Pointing at files.** Once: `@path` in the message. Every session in this repo: `/note` a pointer, never the content. Every time there's a task, anywhere: a skill. Still point at things Claude cannot discover (*tickets, specs, meeting decisions*); the goal is never to point twice.

**Something worth keeping.** `/note it` (repo fact) or edit `CLAUDE.md` in this repo and rerun the installer. Do not use the `#` shortcut for the latter; it writes to the installed copy, which the next install overwrites.

**End of session.** `/log`, or `/log <focus>`. Nothing is logged otherwise.
