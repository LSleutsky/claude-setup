## Setup

| When | Why | Command |
|---|---|---|
| New machine | Build `~/.claude` from this repo | `git clone <repo> ~/dev/claude-setup && cd ~/dev/claude-setup && bash install.sh` |
| New machine | The TypeScript LSP plugin needs its server on PATH, or it silently does nothing | `npm install -g typescript-language-server typescript` |
| Work machine | Read and write sibling repos and the handoff folder without prompts | `jq '.permissions.additionalDirectories = [...]' ~/.claude/settings.json` |
| After any edit to this repo | Push the change to `~/.claude` | `bash install.sh` |
| Something seems ignored | See what loaded and what is registered | `/context` `/hooks` `/permissions` |
| Rules feel contradictory | Audit every instruction file | `/doctor prompt-audit` |

## Repo

| When | Why | Command |
|---|---|---|
| First session in a repo | Learn it once, store it outside the repo | `/map` or `/map <facts Claude cannot see>` |
| Repo changed shape | Refresh the map; notes survive | `/map` |
| Learned something durable | One line into the context file | `/note <fact>` |
| End of session | Record done, decided, encountered, open | `/log` or `/log <focus>` |
| A feature landed, or a TDD is due | Regenerate the design doc from the code | `/design-doc` |

## Work

| When | Why | Command |
|---|---|---|
| Starting a ticket | Plan, phases, one commit message each, tagged with the ticket | `/ac ABC-123 ticket: <paste criteria>` |
| Reviewing the plan | Edit it directly instead of describing changes | `Ctrl+G` |
| After a UI phase | Prove it works at runtime, not just in types | `/verify` |
| Before a PR, or after a big phase | Cold defect review of everything since the default branch, approve fixes by number | `/review` |
| Writing the PR | Short human description, diff stays out of context | `/pr` |
| A bug, no ticket | Fix by sequence, not by guessing | `/debug <symptom, trace, file>` |
| Quick question mid-task | Answer never enters history | `/btw <question>` |
| Need a fact from docs or the web | Sourced claims only, pages stay out of your session | `/research <question>` |

## Stopping and resuming

| When | Why | Command |
|---|---|---|
| Day ends mid-plan | Write everything the next session needs | `/continue <path in Obsidian>` |
| Next session | Pick up at the exact next action, no questions | `/ac <paste the Continue document>` |
| Claude must write to another repo or the handoff folder this session | Approve the prompt once, or unlock the directory for the session | approve, or `/add-dir <path>` |

## Across repos

| When | Why | Command |
|---|---|---|
| Need facts from another repo | `explorer` reads it; code stays out of your session | ask, naming the repo |
| Ticket needs a change elsewhere | One standalone handoff per repo, contract verified in that repo | `/handoff`, then in each repo `/ac <paste>` |
| Two tickets at once | Same context, separate worklog entries | `git worktree add ../<repo>-<branch> -b <branch>` or `claude --worktree` |

## Decisions

| When | Why | Command |
|---|---|---|
| Greenfield | One-page design; slice 1 goes to `/ac` | `/design <what you want>` |
| A real fork | Three isolated opinions, one verdict | `/council <A or B?>` |
| A module has absorbed several tickets, or you inherit a repo | Cold look at the shape, not a diff | `/audit [path]` |

## Corrections

| When | Why | Command |
|---|---|---|
| Same correction twice in a session | Context is polluted with failed attempts | `/clear`, then `/ac` again plus one line on what not to do |
| Wrong everywhere, not just this repo | The rule belongs to you, not the repo | one sentence in `CLAUDE.md` or the matching `rules/` file, `bash install.sh` |
| A new JS or TS house convention | Lives with the language rules | a bullet under `## Conventions` in `rules/javascript.md`, `bash install.sh` |
| Monthly | Keep every file earned | delete unflagged rules, stale notes, unused skills (`/skill-doctor`) |
