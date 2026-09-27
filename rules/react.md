---
paths:
  - "**/*.{tsx,jsx}"
---

# React

- Functional components and hooks only. No class components.
- `export default function Component() {}`. Not `const Component` followed by a separate `export default`.
- One component per file. Extract child components to their own namespaced files. Exception: a small pure helper doing one or two things stays in the same file, defined with `const` above the default export, with the component JSDoc format.
- Components are small, single-purpose, and easy to reason about. Decompose before they become hard to test or extend.
- No business logic in JSX.
- Logic used three or more times lives in a custom hook or pure function.
- Side effects are isolated, explicit, and fully cleaned up. An effect is for syncing with something outside React, never for computing a value or reacting to a prop change.
- Every async UI path defines loading, empty, error, and success states.
- Every form handles validation, submission states, and accessibility explicitly. Target WCAG 2.2 AA.
- Reserve layout space with CSS (`min-w-*`, `min-h-*`, pseudo-elements), never with placeholder characters.
- On React 19, `ref` is a regular prop. No new `forwardRef`.

## State

- State lives at the lowest practical level. Lift only when multiple components truly need it; a re-render storm is a state placement bug, not a memoization gap.
- Derive, do not store. Never mirror props or server data into state, and never compute in an effect what can be computed during render.
- Server state is read through the repo's data hooks and shared through their cache, never refetched per component, and never copied into `useState` unless transformation or isolation is required.

## Performance

- Lists are keyed by a stable id, never index. Lists that can exceed a few hundred rows are virtualized.
- Routes and heavy components load lazily. Charts, editors, and anything with a large dependency are never in the initial bundle.
- Images and media carry explicit dimensions to prevent layout shift.
- `memo`, `useMemo`, `useCallback` are added only with a profiler capture showing the re-render they prevent, and the capture is mentioned in the plan. When the repo has React Compiler enabled, never add them.
