---
paths:
  - "**/*.{ts,tsx,mts,cts}"
---

# TypeScript

- Types are the source of truth for data contracts.
- Never widen a type to bypass an error. Fix the data flow instead of reaching for `any`, `unknown`, or a type assertion.
- Declare `interface` and `type` directly after the imports, before any other logic.
- To verify a library API exists, grep the package's `.d.ts` under `node_modules`. Not confirmed there means not used.
- Treat existing `console.info` and `console.error` as intentional. `console.log` is for development tracing only and does not ship.

## JSDoc

- Single-line comments use `//`. Never `/** text */` on one line.
- Multi-line comments and all doc comments use the block form: `/**` on its own line, each line starting with ` * `, `*/` on its own line. One short sentence per line.
- Only on exported components, custom hooks, and standalone utility files. Never on `useCallback`, `useEffect`, or helpers defined inside a component body.
- One sentence per line. Short sentences. Concise, high level, unambiguous.
- Blank line between the description and the first `@param`. All `@param` lines grouped with no blank lines between them. Blank line between the last `@param` and `@returns`.
- `@returns` always carries the type: `@returns {boolean} Whether the device was paired`.
- One `@example` only when it significantly improves understanding of a complex function.
- Components: a one or two line description, a blank line, then a short `@returns {JSX.Element} ...`.
- Any identifier referenced in JSDoc or a comment goes in backticks.
