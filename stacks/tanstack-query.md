# TanStack Query

- Query keys come from one factory per domain (`participantKeys.list(studyId)`), never inline arrays. Invalidation targets the narrowest key that is actually stale, never the whole cache.
- Mutations use `useMutation` with explicit `invalidateQueries` or `setQueryData` in `onSuccess`. Optimistic updates only when the task asks for them.
- Server state lives in the query cache. Never copied into Zustand, context, or `useState`; Zustand is for client-only state.
- `staleTime` is set per query with a reason. A `staleTime` of zero on data that rarely changes is a refetch storm waiting to happen.
