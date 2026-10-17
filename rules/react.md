---
paths:
  - "**/*.{tsx,jsx}"
---

# React

The repo's existing way of doing each of these wins; these apply where it has none. They assume React 19.2 or newer: check `package.json` first, and on an older version use that version's API and say so.

- Function components and hooks. The only class is an error boundary, and an existing boundary or `react-error-boundary` comes before writing one.
- `export default function Component() {}`. One component per file; a small pure helper used only by that component may sit above it.
- Never define a component inside another component: it becomes a new type on every render and resets its state.
- Components are small and single-purpose. No business logic in JSX; compute above the `return`.
- An effect only syncs with something outside React (subscriptions, DOM, timers, non-React libraries) and returns its cleanup. Never an effect to compute a value, mirror a prop, or react to a prop change: derive during render, or change the `key` to reset state.
- Logic an effect calls without retriggering it goes in `useEffectEvent`, declared in the same component, called only from the effect, never listed as a dependency.
- Data comes from the repo's query library or route loader. Never fetch in an effect. External stores connect through `useSyncExternalStore`. App-once setup lives at module level, not in `useEffect` with an empty dependency array.
- An async UI path you add defines loading, empty, error, and success. Loading is a Suspense fallback or `isPending`; errors reach an error boundary placed at a logical grouping (a list, a panel), not around every element.
- `use(promise)` reads a promise created before render (loader, server, event, cache); never create it during render. `lazy()` is declared at module level and rendered inside Suspense.
- `ref` is a regular prop; no new `forwardRef`. `<Context value>`, not `<Context.Provider>`. Ref callbacks return their cleanup.
- Web forms: `<form action={fn}>` with `useActionState` for state and pending; `useFormStatus` from a child rendered inside the form; `useOptimistic` set only inside the action. Expected errors return as state; unexpected ones throw. A form you add has validation, submission states, and labels.
- Reserve layout space with CSS, never with placeholder characters. Images and media carry explicit dimensions.

## State

- State lives at the lowest level that needs it. Lift only when two components truly share it; a re-render storm is a placement bug, not a memoization gap.
- Derive, do not store. A prop copied into state is only for ignoring later updates, and is named `initialX` or `defaultX`.
- Server state lives in the query cache, never copied into `useState` or a client store unless transformed or isolated. Client-only state (UI, drafts) stays out of the query cache.
- A side effect triggered by a user action runs in the handler, not in an effect watching state.

## Performance

- Keys are stable ids from the data, unique among siblings, never the index, never generated during render.
- A route or heavy component you add (charts, editors, anything with a large dependency) loads lazily; existing imports stay as they are.
- `memo`, `useMemo`, `useCallback` only when a measurement (Profiler or `console.time` on a production build) shows the cost, or when the value is a dependency that must stay stable. With React Compiler enabled, never add them; leave existing ones alone.
- `useTransition` or `useDeferredValue` keep the current UI visible during slow updates; a deferred child must be memoized or the deferral does nothing.
- A list is virtualized only when a measurement shows it needs to be, never because it might grow.

## Structure

Follow the repo's layout. When creating a new area where the repo has no pattern:

- Group by feature, not by type: `features/<name>/` holds that feature's components, hooks, api calls, and types together. A primitive moves to `components/ui/` only once a second feature uses it.
- Routes and screens are thin: they compose feature components and own no data logic.
- No barrel `index` files; import from the file. No `utils/` or `helpers/` folder; a helper lives next to its only caller until a third caller exists.
- Tests sit next to the file they test.
