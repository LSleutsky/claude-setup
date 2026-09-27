# TanStack Router and Start

- Route loaders own data. `loader` calls `queryClient.ensureQueryData`; the component reads with `useSuspenseQuery` on the same key. A component that fetches on mount is a bug.
- Search params go through `validateSearch` with the repo's validator. Never `URLSearchParams` by hand, never untyped `search`.
- Params and search come from `Route.useParams()` and `Route.useSearch()`, never prop-drilled from a parent.
- `pendingComponent` and `errorComponent` on every route that loads data. `pendingMs` and `pendingMinMs` set deliberately, not defaulted, on routes users hit often.
- `createServerFn` handlers validate input and are the only place server-only code runs. Secrets never cross into loaders or components.
- Navigation uses `<Link to>` and `useNavigate` with typed routes. Never string hrefs.
- `routeTree.gen.ts` is generated. Never edited, never hand-fixed to satisfy a type error.
