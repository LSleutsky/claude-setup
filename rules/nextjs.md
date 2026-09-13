---
paths:
  - "**/app/**/{page,layout,template,loading,error,not-found,route,default}.{ts,tsx,js,jsx}"
  - "**/app/**/actions.{ts,tsx}"
  - "**/middleware.{ts,js}"
  - "**/next.config.{js,mjs,ts}"
  - "**/instrumentation.{ts,js}"
---

# Next.js (App Router)

- Server Components by default. `"use client"` goes on the smallest leaf that needs state, effects, or browser APIs, never on a layout or page. A client boundary that receives server data as props is the pattern; a client boundary that fetches is a bug.
- Data is fetched where it is rendered, in Server Components or route handlers. No client-side fetching of data that was available at render time.
- Mutations are Server Actions or route handlers. Every one validates its input on the server with the validator the repo already uses. The client is never trusted.
- Caching is explicit. Every `fetch` and every data function states its cache or `revalidate` behavior, and the plan says whether the route is static or dynamic and why. Tag-based revalidation over time-based when a mutation is known.
- `loading.tsx` and `error.tsx` exist for every route segment that fetches. Suspense boundaries are placed deliberately, around the slow part, not the whole page.
- `next/image`, `next/link`, `next/font`. Never raw `<img>`, never `<a>` for internal navigation.
- Metadata through the `metadata` export or `generateMetadata`, never manual `<head>` tags.
- Secrets are read only in server code. `NEXT_PUBLIC_` is for values that are safe in the bundle, nothing else.
- Route handlers and actions are thin: parse, validate, call, return. Business logic lives in a plain module they import.
- Middleware stays minimal and edge-safe. No database, no heavy libraries, no work that belongs in a route.
- Never hand-edit `.next/`. Never disable type or lint checks in `next.config` to make a build pass.
