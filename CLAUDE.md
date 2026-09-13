<!--
Judgement rules only, language-free. Loaded into every session on every machine. Mechanical rules are not here on purpose: formatting, linting and typechecking run from hooks/; command gating lives in settings.json; language rules are path-scoped in rules/ and cost nothing until a matching file is touched. Block-level HTML comments are stripped before injection and cost zero tokens.
-->

# Working agreement

## Before writing code

- A task is non-trivial if it touches more than one file, adds a new data flow or abstraction, or has non-local side effects. For non-trivial tasks: enter plan mode, write a concise plan, wait for approval. Files named in an approved plan need no separate approval.
- Plan phases as vertical slices. Each phase leaves the code working, reviewable, and complete for one behavior. Never split by layer (all types, then all UI).
- Ask when ambiguity affects architecture, data contracts, or user-visible behavior. Batch every question into one message. Resolve trivial ambiguity yourself and state the assumption inline.
- Two valid approaches that would produce different outputs or APIs: present the tradeoff. Never choose silently.
- Required context missing (schema, API shape, component contract): stop and ask. Never invent it.
- Never assume a library API exists. Confirm it in the codebase or in the installed package's own source or type definitions. If unverified, use a native implementation. Do not infer capabilities from naming.
- Knowledge that is not in the code (product decisions, why a contract looks the way it does) is not yours to infer. Ask. If the answer will matter again, say so, so it can be saved with `/note`.
- Reach the backend only through the client this codebase already uses. Never add a base URL, call another service directly, or bypass an existing gateway. If a task seems to need that, it is a question.

## While working

- Surface blockers immediately. Mechanical retries (typos, flags, paths) are fine; stop when the approach itself has to change.
- Propose solutions, not just problems.
- Do not narrate trivial work. When continuing a previous task, state which assumptions are carried forward.
- Touch only files the task requires. No opportunistic cleanup, renaming, refactoring, or extra error handling, logging, or comments. Never rename, move, or delete files without explicit approval.
- Ask before creating a new file: propose the name and location first.
- Never label breakage you caused as pre-existing. Report pre-existing failures in untouched files by file and line; do not fix them without asking.
- Tests: do not run them unprompted. When a run fails because of your change, fix the code, never the assertion.
- Use the package manager the lockfile indicates, its commands only, never mixed. Never run an install to "see if it fixes it."
- Commit messages are one line: `type(scope): what changed`, imperative, under 100 characters, no period, no body. `fix(ble): retry pairing after timeout`.

## Code

- Explicit over implicit. Default to the simplest change that is obviously correct. If that change deletes code, delete it.
- Match the surrounding code exactly: whitespace, brace placement, import grouping and order, naming, how a file is organized. The formatter decides formatting; for everything it does not decide, the file you are in decides. Existing structure is followed, not improved, unless it is itself an unearned pattern on the `Earn it` list.
- Replace, do not deprecate: when new replaces old, delete the old. No migration shims. Published packages are the exception: deprecate in a minor, remove in the next major. Assume every change is a minor unless told otherwise.
- Semantic names (`minWithdrawalAmount`, not `min`).
- No silent failures. Never an empty catch: rethrow, return an explicit error state, or pass to the application error handler. Expected failures are modeled as explicit states, not thrown. Domain errors get specific error types. User-facing errors are actionable and non-technical.
- Leave existing intentional logging in place; update a message only if a structural change made it wrong. No stray debug output in production code.
- Performance is a correctness concern at the design level and a measurement concern after that. At design time: no N+1 or repeated fetches for data already in hand, no unbounded lists or payloads, no work in a hot path that could happen once, nothing blocking the main thread that could be deferred. After that, optimize only with a profile showing the cost, and say what it showed.
- Avoid pathological patterns (accidental O(n^2), redundant requests, redundant re-renders).

## Earn it

Each of these is fine when earned and slop when introduced on first use. The plan states the justification; if it cannot, the pattern is not used.

- A helper, util, or shared function: earned by a third real call site, or by an existing shared folder the codebase already uses for exactly this.
- A wrapper, adapter, or service around a direct call: earned by two callers that need the same non-trivial behavior around it.
- An interface or abstract type: earned by a second real implementation.
- A parameter, flag, or options object: earned by a second caller passing a different value.
- A hook, context, or store: earned by two components that truly share the state.
- A new file: earned by the task naming it, or by the plan naming it and being approved.
- A try/catch: earned by changing what happens next.

## Writing

Answers first. The first sentence answers the question. No preamble, no restating the question, no options nobody asked for, no summary at the end. If one sentence answers it, one sentence is the whole reply.

Comments are rare, short, and sound like a person. First person plain prose, one sentence, only where the why is not obvious from the code. Multi-line comments: one short sentence per line, three lines at most. Never describe what the next line does. Never a banner, header, or section comment. Wrap referenced identifiers in backticks.

Doc comments follow the language rules in `rules/` and are written the way you would say it to the person next to you, not the way documentation reads.

Bad:
`// This function is responsible for validating the incoming payload and ensuring that all required fields are present before processing.`
Good:
`// Reject early so the queue never sees a partial payload.`

Bad:
`/** Retrieves the current user's active session from the store and returns it, or undefined if no session exists. */`
Good:
```
/**
 * Active session, or undefined when logged out.
 */
```

Never use em dashes or any non-ASCII character anywhere: prose, markdown, code, comments, doc comments, commit messages. Use a comma or split the sentence. Only exception: code whose purpose is processing such characters.

Markdown: italicize text inside conversational parentheses; every code reference in backticks; fenced blocks carry a language tag.
