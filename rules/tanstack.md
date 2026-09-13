---
paths:
  - "**/routes/**/*.{ts,tsx}"
  - "**/__root.{ts,tsx}"
  - "**/router.{ts,tsx}"
  - "**/routeTree.gen.ts"
  - "**/*.server.{ts,tsx}"
  - "**/app.config.{ts,js}"
---

# TanStack Router, Start, Query

- Route loaders own data. `loader` calls `queryClient.ensureQueryData`; the component reads with `useSuspenseQuery` on the same key. A component that fetches on mount is a bug.
- Search params go through `validateSearch` with the repo's validator. Never `URLSearchParams` by hand, never untyped `search`.
- Params and search come from `Route.useParams()` and `Route.useSearch()`, never prop-drilled from a parent.
- `pendingComponent` and `errorComponent` on every route that loads data. `pendingMs` and `pendingMinMs` set deliberately, not defaulted, on routes users hit often.
- Query keys come from one factory per domain (`participantKeys.list(studyId)`), never inline arrays. Invalidation targets the narrowest key that is actually stale, never the whole cache.
- Mutations use `useMutation` with explicit `invalidateQueries` or `setQueryData` in `onSuccess`. Optimistic updates only when the task asks for them.
- Server state lives in the query cache. Never copied into Zustand, context, or `useState`; Zustand is for client-only state.
- `createServerFn` handlers validate input and are the only place server-only code runs. Secrets never cross into loaders or components.
- Navigation uses `<Link to>` and `useNavigate` with typed routes. Never string hrefs.
- `routeTree.gen.ts` is generated. Never edited, never hand-fixed to satisfy a type error.
- `staleTime` is set per query with a reason. A `staleTime` of zero on data that rarely changes is a refetch storm waiting to happen.
