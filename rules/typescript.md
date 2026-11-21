---
paths:
  - "**/*.{ts,tsx,mts,cts}"
---

# TypeScript

The repo's existing way of doing each of these wins; these apply where it has none.

- Types are the source of truth for data contracts.
- Never widen a type to bypass an error. Fix the data flow instead of reaching for `any`, a type assertion, or a non-null `!`. Assertions and `!` are erased, never checked; `!` only where the value is provably present on that line.
- If a suppression is unavoidable, `@ts-expect-error` with the reason on the same line. Never `@ts-ignore`.
- Data from outside the process (responses, params, storage, `JSON.parse`) is `unknown` until the repo's validator parses it. Infer the type from that schema; never declare the same shape twice. With no validator in the repo, a type guard at the boundary; a schema library enters only through the plan.
- Narrow with type guards and discriminated unions, never with assertions. A `switch` over a union is exhaustive: `default` assigns the value to `never`.
- `satisfies` checks a literal against a type without widening it: config objects, lookup tables, route maps.
- Index access can be `undefined` under `noUncheckedIndexedAccess`; handle it at the access, not with `!`.
- No `enum`; a union of string literals or an `as const` object replaces it. When the repo sets `erasableSyntaxOnly`, also no `namespace` with runtime code and no constructor parameter properties. NestJS repos keep their `private readonly` constructor injection.
- Declare `interface` and `type` directly after the imports, before any other logic.
- Never lower `strict`, add `ignoreDeprecations`, or widen `include` to make a build pass. TypeScript 6 deprecates `baseUrl`; new path mapping uses `paths`.

## JSDoc / Comments

- Single-line comments use `//`. Never `/** text */` on one line.
- Multi-line comments and all doc comments use the block form: `/**` on its own line, each line starting with ` * `, `*/` on its own line. One short sentence per line.
- Required on every exported component, custom hook, and exported function you create. Never on anything else: functions inside a component body (handlers, `useCallback`, `useEffect`, helpers), functions nested inside another function, or helpers the module does not export.
- The description is one or two short sentences saying what the thing does, not how. Add one sentence for anything the signature cannot show: a unit, a valid range, a side effect, or what a null or empty result means.
- `@param name - Description` for every parameter, in declaration order, none omitted, with no blank lines between them. The name exactly as declared, a hyphen with one space on each side, then a short description that includes any unit or constraint.
- `@returns {type} Short Description` on every function that returns a value, saying what it is, including any unit or what null or empty means. Never on components or functions that return nothing.
- `@throws {ErrorClass} When ...` for each error a caller is expected to handle.
- `@deprecated` with its replacement, only in a published package.
- One `@example` only when the function's use is ambiguous or unclear from its name, description, and parameters. Never on components.
- One blank ` *` line between the description and the first tag, and between tags of different kinds: the `@param` group, `@returns`, `@throws`, and `@example` are each separated by one.
- Components: a one or two line description and nothing else.
- Any identifier referenced in JSDoc or a comment goes in backticks.
