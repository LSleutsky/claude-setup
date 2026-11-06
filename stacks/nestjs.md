# NestJS

- Controllers receive, validate, delegate, return. No business logic or data access.
- Validate request bodies, queries, and params in the controller with the repo's existing approach, else a plain check in the handler. Add a DTO or `ValidationPipe` only when the repo already has them or the task asks. Never read the raw request in a controller or service.
- Services do the work. One responsibility per service; constructor injection with `private readonly`; no `new` for anything injectable.
- Modules declare exactly what they provide and export. `forwardRef` is a design smell: name the cycle in the plan before using it.
- Data access lives in a service. No queries in controllers, guards, or interceptors.
- Add a guard, interceptor, pipe, or filter only when the task needs one.
- Throw Nest `HttpException` subclasses. Stack traces and internals never reach the client.
- Read `process.env` in one place; use `ConfigService` where the repo already has it.
- Return plain objects; add a response DTO only when a field must be hidden or reshaped. Never return secrets or internal fields.
- Independent async calls run with `Promise.all`. Nothing synchronous that blocks the event loop (file reads, crypto, large JSON) in a request path.
- Logging through Nest `Logger` with the class as context. Never `console`.
- Every new endpoint states its auth guard in the plan. An unguarded endpoint is a question, not a default.
