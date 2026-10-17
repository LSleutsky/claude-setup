# Working agreement

IMPORTANT: the deliverable is the smallest change that does exactly what was asked and is verified. Nothing else. The failure to avoid is not a missing feature; it is a diff bigger than the task.

## Scope

- Only make changes that are directly requested or clearly necessary.
  - No features, refactors, renames, reformatting, or "improvements" beyond the ask. A bug fix fixes the root cause at one site and touches nothing else. A simple feature does not get configurability.
  - No docstrings, comments, or type annotations on code you did not change. Comment only where the logic is not self-evident.
  - No error handling, fallbacks, defensive checks, or validation for cases current callers cannot hit. Trust internal code and framework guarantees; validate at system boundaries only (user input, external APIs, other services).
  - No helpers, utilities, wrappers, options, interfaces, hooks, stores, or layers for one use. Two or three repeated lines beat a new abstraction. Extract on the third real call site, never before.
- A new file, export, type, hook, helper, option, or layer exists only when the task cannot be done without it. When you think one is needed, stop and name it with its reason before writing it; in a plan, it appears by name with the uses that earn it.
- Every rule in this file, under `rules/`, and in the framework rules constrains the code you write. None of them is a reason to change a line the task did not need; a violation in untouched code is one line at the end of the reply.
- "Best practice", "clean", "robust", "production-ready", "maintainable", "future-proof", "scalable", "flexible", and "extensible" are not reasons. The only reasons are the task and the pattern this repo already uses.
- Something else worth doing (a pre-existing bug, cleanup, a file the task did not need) is one line at the end of the reply, not a change.
- Ambiguity: implement the reading the wording and the surrounding code most directly support, and state the assumption. Ask only when different readings lead to materially different work, and batch every question into one message.
- Required context missing (schema, API shape, component contract): stop and ask. Never invent it.
- Never assume a library API exists. Confirm it in the repo or in the package's own `.d.ts` under `node_modules`. Unconfirmed means a native implementation.
- Choose an approach and commit to it. When two valid approaches produce different outputs or APIs, present the tradeoff; never choose silently.
- Reach the backend only through the client this codebase already uses. Never add a base URL or call another service directly.

## Workflow

- Plan first (plan mode) when the change spans several files or the approach is uncertain. Skip the plan when the diff fits in one sentence. A plan names each file it touches with the lines it expects to change, names every new file with the reason the task cannot be done without it, and ends with `Not doing:`. Phases are vertical slices; each leaves the build green with one behavior complete and stays under about 150 changed lines, or says in one sentence why not.
- Before the commit message, read `git diff` and delete every line the task did not need: every file, abstraction, option, fallback, check, comment, and blank-line change without a requirement behind it. The Stop hook demands this pass when a turn changes more than its budget.
- Never stage, commit, or push. After each phase: run `git diff --stat`, list every touched file and call out any not in the plan, run the verification below, reply with one commit message, stop.
- Commit message: one line, `type(scope): what changed`, imperative, under 100 characters, no period, no body. When a ticket id is known (from the task, the branch name, a handoff, or a continue doc) the line ends with it in parentheses: `fix(auth): refresh token before expiry (ABC-123)`.
- Never rename, move, or delete a file without approval. Touch only files the task requires.
- Subagents: `explorer` reads other repos and returns locations and contracts; `runner` runs a command with long output and returns the outcome; `researcher` fetches facts that are not in the repo. Do not delegate what a few tool calls finish, and never use a subagent to verify your own work.

## Verification

- Hooks format and lint every edit and typecheck when the turn ends. Fix what they report before replying.
- Before each phase's commit message, run the repo's existing tests for the code touched, through `runner`. Never add tests unless asked or the repo already keeps tests for this kind of change; then one focused test per stated behavior, sized like its neighbors.
- Report evidence: what ran and the result. Never "should work". A failure is reported with its output.
- Never weaken or delete an assertion, suppress an error, or label breakage you caused as pre-existing. Pre-existing failures in untouched files are reported by file and line, not fixed.

## Code

- Before writing anything, find how this repo already does that kind of thing (the nearest similar component, hook, endpoint, query, form, error path, test) and do it the same way. The repo's established idiom beats the rule files under `~/.claude`; those apply where the repo has no established way. A pattern, library, or layout the repo does not already use enters only through the plan, by name.
- Explicit over implicit. The simplest change that is obviously correct. If it deletes code, delete it.
- Match the file you are in: formatting, import order, naming, how it is organized. The formatter and linter decide; where they are silent, the file decides.
- Replace, do not deprecate. Published packages are the exception: deprecate in a minor, remove in the next major.
- Semantic names (`minWithdrawalAmount`, not `min`).
- No silent failures. Never an empty catch. Expected failures are explicit states, not throws. Domain errors use the repo's existing error types; a new one is named in the plan or not written. User-facing errors say what to do, not what broke inside.
- Keep existing intentional logging. No stray debug output.
- Performance at design time: no N+1, no accidental O(n^2), no refetch of data already in hand, no unbounded lists or payloads, nothing on the main thread that could be deferred. Beyond that, optimize only with a profile, and say what it showed.
- Use the package manager the lockfile indicates. Never install to see if it fixes something.
- Comments: rare, one sentence, why not what, plain first person, identifiers in backticks. Never a banner, never a comment that restates the next line.

## Structure

- Dependencies point one way: UI depends on domain, domain on data access, never the reverse. A circular import is a design error.
- A data contract is defined once, at the boundary it crosses, and imported everywhere else.
- One way to do each thing. Use the dominant existing pattern and say so; never introduce a third.
- A concept lives in one place. When a change would touch the same concept in three files, say so in the reply; consolidating it is its own task, never a side effect of this one.
- Small and deletable beats indirection. Name the second concrete use or drop the pattern.

## Security

- Validate at every trust boundary: request bodies, params, query strings, webhooks, uploads, other services. Inside the boundary, trust the type.
- Every endpoint, action, and route states its authorization in the plan. Default deny; an unguarded path is a question.
- Secrets live in the environment and are read in one place. Never in code, logs, errors, client bundles, or commit messages.
- Parameterized queries. Never string-build SQL, shell commands, or HTML from input.
- Stack traces, internal paths, and library messages never leave the server.
- Personal data never appears in logs, notes, fixtures, or context files.
- No new dependency for what the platform or an existing dependency already does. The plan names why a dependency is worth its attack surface.
- No `eval`, no dynamic code from input, no disabling a security header, CORS rule, or CSP.

## Writing

- Answers first. If one sentence answers it, one sentence is the reply. No preamble, no options nobody asked for, no summary at the end.
- ASCII only. Never an em dash or any non-ASCII character in prose, code, comments, or commit messages, unless the code processes such characters.
- Markdown: code references in backticks, fenced blocks carry a language tag.
- When compacting, preserve verbatim: the approved plan and the current phase, the full list of modified files, every decision with its reason, the ticket id, typecheck, lint, and test results, and open items.
