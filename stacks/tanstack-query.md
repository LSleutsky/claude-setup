# TanStack Query

- Query keys come from the repo's key factory for that domain if it has one, else inline arrays; add a factory only at the third use. Invalidation targets the narrowest key that is actually stale, never the whole cache.
- Mutations use `useMutation` with explicit `invalidateQueries` or `setQueryData` in `onSuccess`. Optimistic updates only when the task asks for them.
- Server state lives in the query cache. Never copied into Zustand, context, or `useState`; Zustand is for client-only state.
