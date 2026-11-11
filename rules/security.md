---
paths:
  - "**/*{[Aa]uth,[Ss]ession,[Tt]oken,[Cc]ookie,[Ll]ogin,[Ss]ign[Ii]n,[Jj][Ww][Tt],[Pp]assword,[Cc]redential,[Mm]iddleware,[Gg]uard,[Pp]roxy}*"
  - "**/*{[Aa]uth,[Ss]ession,[Tt]oken,[Cc]ookie,[Ll]ogin,[Ss]ign[Ii]n,[Jj][Ww][Tt],[Pp]assword,[Cc]redential,[Mm]iddleware,[Gg]uard,[Pp]roxy}*/**"
---

# Security (auth, sessions, tokens)

The repo's existing auth library and session handling win; never hand-roll what they already do. Each line applies only to code you write that does the thing it names. None is a reason to add a security feature the task did not ask for; a hole in untouched code is one line at the end of the reply.

- Session ids and tokens on the web live in cookies set `HttpOnly`, `Secure`, and `SameSite`. Never in `localStorage`, `sessionStorage`, or a URL.
- A JWT is trusted only after its signature is verified with the algorithm pinned in code and `exp` is checked, plus `iss` and `aud` where the token carries them. Decoding is not verifying. Nothing secret goes in the payload.
- OAuth uses the authorization code flow with PKCE. `state` is generated per request and checked on return. Redirect URIs match exactly.
- A request that changes state and is authenticated by a cookie uses the framework's CSRF protection, else a CSRF token. `SameSite` alone is not enough.
- Authorization runs on the server and checks the caller's right to the specific record, by owner or tenant, on every read and write by id.
- A redirect target taken from input is a relative path or on an allow-list. A server-side fetch of a URL taken from input is limited to an allow-list of hosts when the destinations are known; when they are not, it is a question.
- Passwords go through the repo's existing hasher, else an Argon2id library named in the plan, else `crypto.scrypt`. Never a plain or fast hash.
- Secrets, tokens, and signatures are compared with `crypto.timingSafeEqual`, never `===`.
- Tokens, ids, and codes that must be unguessable come from `crypto.randomUUID` or `crypto.getRandomValues`, never `Math.random`.
- Login, signup, and reset responses do not reveal whether an account exists.
