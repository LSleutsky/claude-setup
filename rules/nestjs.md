---
paths:
  - "**/*.{controller,service,module,guard,interceptor,pipe,filter,middleware,dto,entity,resolver,gateway,strategy}.ts"
  - "**/main.ts"
---

# NestJS

- Controllers are thin: receive, validate, delegate, return. No business logic, no data access, no conditionals beyond routing the call.
- Every request body, query, and param is a DTO validated by the global `ValidationPipe` with `whitelist` and `forbidNonWhitelisted`. Never read the raw request in a controller or service.
- Services do the work. One responsibility per service; constructor injection with `private readonly`; no `new` for anything injectable.
- Modules declare exactly what they provide and export. `forwardRef` is a design smell: name the cycle in the plan before using it.
- Data access goes through a repository or the ORM inside a service. No queries in controllers, guards, or interceptors.
- Cross-cutting concerns have a home: guards for auth, interceptors for logging and mapping, pipes for transform and validate, filters for error shape. None of these live in a service.
- Throw Nest `HttpException` subclasses at the HTTP boundary only. Domain code throws domain errors; one exception filter maps them. Stack traces and internals never reach the client.
- Configuration comes from `ConfigService` backed by a validated schema. No `process.env` outside the config module.
- Responses are mapped to response DTOs. Entities and ORM models never leave the service layer.
- Independent async calls run with `Promise.all`. Nothing synchronous that blocks the event loop (file reads, crypto, large JSON) in a request path.
- Logging through Nest `Logger` with the class as context. Never `console`.
- Every new endpoint states its auth guard in the plan. An unguarded endpoint is a question, not a default.
