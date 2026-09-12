---
paths:
  - "**/*.{tsx,jsx}"
---

# React

- Functional components and hooks only. No class components.
- `export default function Component() {}`. Not `const Component` followed by a separate `export default`.
- One component per file. Extract child components to their own namespaced files. Exception: a small pure helper doing one or two things stays in the same file, defined with `const` above the default export, with the component JSDoc format.
- Components are small, single-purpose, and easy to reason about. Decompose before they become hard to test or extend.
- State lives at the lowest practical level. Lift only when multiple components truly need it. Never store derived values in state.
- Server state (API data) is consumed through hooks, not copied into `useState`, unless transformation or isolation is required.
- Side effects are isolated, explicit, and fully cleaned up.
- No business logic in JSX.
- Logic used three or more times lives in a custom hook or pure function.
- Every async UI path defines loading, empty, error, and success states.
- Every form handles validation, submission states, and accessibility explicitly. Target WCAG 2.2 AA.
- Reserve layout space with CSS (`min-w-*`, `min-h-*`, pseudo-elements), never with placeholder characters.
- Prefer Server Components for data fetching where the framework supports it.
- Memoization and other optimization only with evidence, never speculatively.
