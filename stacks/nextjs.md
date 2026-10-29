# Next.js (App Router)

The repo's existing way of doing each of these wins; these apply where it has none. They assume Next.js 16 or newer. Check `package.json` first; on an older major use that version's API and say so.

- Server Components by default. `"use client"` goes on the file that defines the interactive component, never on a large part of the tree. A client component receives server data as props; it fetches only data that did not exist at render time, through the repo's query library.
- Data is fetched where it is rendered, in Server Components or route handlers. No client-side fetching of data that was available at render time.
- Mutations are Server Actions or route handlers. Every one validates its input on the server with the validator the repo already uses, and checks authorization itself, because an action is reachable by a direct POST. The client is never trusted.
- `fetch` is not cached by default. Caching is the `use cache` directive under `cacheComponents: true`: every `use cache` scope sets `cacheLife` explicitly and `cacheTag` for what invalidates it. `revalidateTag(tag, profile)`, never the one-argument form; `updateTag` inside a Server Action when the change must show immediately. Tag-based revalidation over path-based. The plan says whether a route is static or dynamic and why.
- A route segment you add that fetches gets `loading.tsx` and `error.tsx`. Suspense boundaries sit around the uncached or runtime data access, not the whole page. `error.tsx` is a client component; its `retry` is what the retry button calls.
- `next/image`, `next/link`, `next/font`. Never raw `<img>`, never `<a>` for internal navigation.
- Metadata through the `metadata` export or `generateMetadata`, from Server Components only, never manual `<head>` tags.
- Secrets are read only in server code, in the data access layer. `NEXT_PUBLIC_` is for values that are safe in the bundle, nothing else.
- Route handlers and actions are thin: parse, validate, call, return. Business logic lives in a server-only module they import.
- `proxy.ts` (the former `middleware.ts`) runs on Node.js and does not support the `edge` runtime. Its checks stay fast, it holds no business logic, and it exists only when no route-level option does the job.
- Never hand-edit `.next/`. `typescript.ignoreBuildErrors` stays off. `next build` no longer lints: lint runs through the ESLint CLI with `eslint-config-next`, whose `no-img-element`, `no-html-link-for-pages`, and `no-head-element` rules back the lines above.
