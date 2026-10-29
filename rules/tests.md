---
paths:
  - "**/*.{test,spec}.{ts,tsx,js,jsx,mts,cts}"
  - "**/__tests__/**"
---

# Tests

The repo's existing test style wins: its runner, its helpers, its file placement, its naming. These apply where it has none.

- Test behavior through the public surface, never implementation details. A refactor that keeps behavior must not break a test.
- One behavior per test. The name reads as a sentence stating that behavior.
- A test for a use case covers its failure outcome, not only success.
- Arrange, act, assert, in that order, visibly.
- Never mock the unit under test. Mock only what crosses a real boundary (network, clock, storage).
- Assert on outcomes, not on calls, unless the call is the contract.
- No conditionals or loops inside a test body.
- Do not weaken or delete an assertion to make a test pass. Fix the code, or say the test was wrong and why.
- Existing tests define current behavior; changing one is a behavior change and is called out as such.
- No snapshot tests for UI; assert the behavior the user sees. End-to-end flows live in the repo's E2E tool, not in unit tests.

## Testing Library (web and React Native)

- Query by role with a name first, then label text, then visible text. `*ByTestId` last, only when nothing else identifies the element. Never add a role, `aria-*`, or `testID` to make a query pass.
- `userEvent` over `fireEvent`: `const user = userEvent.setup()` before `render`, and await every call.
- `find*` for anything that appears later; `query*` only to assert absence; `waitForElementToBeRemoved` for disappearance. One assertion per `waitFor`, no side effects inside it.
- Query through `screen`. No manual `act`, no manual `cleanup`.
- Fake timers are enabled in `beforeEach`, pending timers run and real timers return in `afterEach`, and `userEvent` gets `advanceTimers`.
