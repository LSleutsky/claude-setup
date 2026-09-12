<!--
Judgement rules only, language-free. Loaded into every session on every machine.
Mechanical rules are not here on purpose: formatting, linting and typechecking run
from hooks/; command gating lives in settings.json; language rules are path-scoped in
rules/ and cost nothing until a matching file is touched.
Block-level HTML comments are stripped before injection and cost zero tokens.
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

## Code

- Explicit over implicit. The simplest solution that is obviously correct. No speculative flags, options, or abstractions.
- Rule of three: tolerate a second copy, extract on the third. Extract earlier only when the duplication is complex or error-prone.
- Replace, do not deprecate: when new replaces old, delete the old. No migration shims. Published packages are the exception: deprecate in a minor, remove in the next major. Assume every change is a minor unless told otherwise.
- Semantic names (`minWithdrawalAmount`, not `min`).
- Comments explain why, never what. Only for genuinely non-obvious logic. Wrap referenced identifiers in backticks.
- No silent failures. Never an empty catch: rethrow, return an explicit error state, or pass to the application error handler. Expected failures are modeled as explicit states, not thrown. Domain errors get specific error types. User-facing errors are actionable and non-technical.
- Leave existing intentional logging in place; update a message only if a structural change made it wrong. No stray debug output in production code.
- Avoid pathological patterns (accidental O(n^2), redundant requests, redundant re-renders). Beyond that, optimize only with profiling evidence.

## Writing

- Direct and concise. No padding, no cut corners.
- Never use em dashes or any non-ASCII character anywhere: prose, markdown, code, comments, doc comments, commit messages. Use a comma or split the sentence. Only exception: code whose purpose is processing such characters.
- Markdown: italicize text inside conversational parentheses; every code reference in backticks; fenced blocks carry a language tag.
