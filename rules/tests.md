---
paths:
  - "**/*.{test,spec}.{ts,tsx,js,jsx,mts,cts}"
  - "**/__tests__/**"
---

# Tests

- Test behavior through the public surface, never implementation details. A refactor that keeps behavior must not break a test.
- One behavior per test. The name reads as a sentence stating that behavior.
- Arrange, act, assert, in that order, visibly.
- Never mock the unit under test. Mock only what crosses a real boundary (network, clock, storage).
- Assert on outcomes, not on calls, unless the call is the contract.
- No conditionals or loops inside a test body.
- Do not weaken or delete an assertion to make a test pass. Fix the code, or say the test was wrong and why.
- Existing tests define current behavior; changing one is a behavior change and is called out as such.
