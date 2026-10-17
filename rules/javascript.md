---
paths:
  - "**/*.{js,jsx,mjs,cjs,ts,tsx,mts,cts}"
---

# JavaScript and TypeScript

The repo's existing idioms, formatter, and linter win. Where they are silent, these apply.

## Imports

- Every import at the top of the file, one module per statement, alphabetized by module path within its group, groups separated by one blank line, in this order:
  1. Runtime and built-ins: `node:*`, `react`, `react-dom`, `react-native`.
  2. Third-party packages.
  3. Internal, one group per role, in this order: providers and contexts, components, hooks, lib (api clients, services, utils), types (`import type`), styles and assets.
  4. Side-effect imports (`import './polyfills'`) last.
- Vanilla (no React): built-ins, third-party, internal by distance (aliases, then `../`, then `./`), types, side effects.
- `import type` for anything used only as a type. Import from the file, never from a barrel `index` that re-exports a folder.

## Layout

- Semicolons always.
- Braces always: `if`, `else`, `for`, `while`, `do`, and arrow functions with more than one expression. No brace-less single-statement bodies.
- Single-line `const` and `let` declarations sit together with no blank line between them.
- A declaration that spans more than one line has one blank line before and after it.
- One blank line before every `return` unless it is the only statement in its block.
- One blank line before and after any statement that opens or closes a block: a function, class, loop, conditional, `try`, `switch`, or a multi-line object or array assignment. Not when it is the first or last statement in its enclosing block.
- `const` by default. `let` only when reassigned. Never `var`.
- Early return over nested conditions. No `else` after a `return`.

## Naming

- Every name says what the thing is or does: `minWithdrawalAmount`, `isSubmitting`, `fetchParticipants`, `participantsById`. Never `data`, `item`, `val`, `temp`, `res`, `obj`, `arr`, or a single letter outside an index loop.
- Booleans read as questions: `is`, `has`, `can`, `should`.
- Functions start with a verb. Handlers are `handleX` inside a component and `onX` as a prop.
- Parameters and props are named for what they carry, not their type: `participant`, not `p` or `obj`.

## Language

- Strict equality. Optional chaining and nullish coalescing over manual null checks.
- `async` and `await`. No floating promise: await it, return it, or `void` it with a one-line reason. Independent async work runs through `Promise.all`.
- Throw `Error` or a subclass with a message, never a string or a plain object. `catch (error)` is `unknown`: narrow before use.
- ESM modules. Nothing runs at import time beyond definitions.
- Built-ins over helper packages: `Array.prototype.at`, `structuredClone`, `Object.groupBy`, `Intl`, `URL`, `AbortController`. No dependency for one function.
- No `eval`, `new Function`, `with`, `arguments`, or prototype mutation.
- `console.log` does not ship. Existing `console.info` and `console.error` are intentional; keep them.

## Conventions

House conventions added over time, one bullet each. Edit this list in the setup repo and rerun the installer.
