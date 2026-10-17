---
paths:
  - "**/*.{ts,tsx,mts,cts}"
---

# TypeScript

The repo's existing way of doing each of these wins; these apply where it has none.

- Types are the source of truth for data contracts.
- Never widen a type to bypass an error. Fix the data flow instead of reaching for `any`, a type assertion, or a non-null `!`. Assertions and `!` are erased, never checked; `!` only where the value is provably present on that line.
- If a suppression is unavoidable, `@ts-expect-error` with the reason on the same line. Never `@ts-ignore`.
- Data from outside the process (responses, params, storage, `JSON.parse`) is `unknown` until the repo's validator parses it. Infer the type from that schema; never declare the same shape twice.
- Narrow with type guards and discriminated unions, never with assertions.
- `satisfies` checks a literal against a type without widening it: config objects, lookup tables, route maps.
- Index access can be `undefined` under `noUncheckedIndexedAccess`; handle it at the access, not with `!`.
- No `enum`; a union of string literals or an `as const` object replaces it. When the repo sets `erasableSyntaxOnly`, also no `namespace` with runtime code and no constructor parameter properties. NestJS repos keep their `private readonly` constructor injection.
- Declare `interface` and `type` directly after the imports, before any other logic.
- To verify a library API exists, grep the package's `.d.ts` under `node_modules`. Not confirmed there means not used.
- Never lower `strict`, add `ignoreDeprecations`, or widen `include` to make a build pass. TypeScript 6 deprecates `baseUrl`; new path mapping uses `paths`.

## JSDoc

- Single-line comments use `//`. Never `/** text */` on one line.
- Multi-line comments and all doc comments use the block form: `/**` on its own line, each line starting with ` * `, `*/` on its own line. One short sentence per line.
- Only on exported components, custom hooks, and standalone utility files. Never on `useCallback`, `useEffect`, or helpers defined inside a component body.
- One sentence per line. Short sentences. Concise, high level, unambiguous.
- Blank line between the description and the first `@param`. All `@param` lines grouped with no blank lines between them. Blank line between the last `@param` and `@returns`.
- `@returns` always carries the type: `@returns {boolean} Whether the device was paired`.
- One `@example` only when it significantly improves understanding of a complex function. Blank line between `@example` and `@returns`.
- Components: a one or two line description, a blank line, then a short `@returns {JSX.Element} ...`.
- Any identifier referenced in JSDoc or a comment goes in backticks.
