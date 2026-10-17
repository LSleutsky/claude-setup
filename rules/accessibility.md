---
paths:
  - "**/*.{tsx,jsx,html,vue,svelte,astro}"
---

# Accessibility (web)

Target WCAG 2.2 AA. The repo's existing accessible components and patterns are reused before anything new is built. React Native accessibility is in the React Native stack rules. Every item below is checkable in the diff.

- Semantic elements before ARIA. `button`, `a`, `nav`, `main`, `label`, `table` before `div` with a role. ARIA only when no native element carries the meaning; a role is a promise to implement its keyboard behavior.
- Every interactive element is reachable and operable by keyboard, in a sensible order, with a visible focus state at 3:1 against its surroundings. Nothing responds only to hover or pointer. The focused element is never hidden behind sticky headers, footers, or panels.
- Every input has a programmatic label. Placeholder is not a label. Fields that collect the user's own data carry `autocomplete`.
- The accessible name of a control contains its visible label text.
- Every image has `alt`; decorative images have `alt=""`.
- Color never carries meaning alone. Text contrast at least 4.5:1; large text, UI parts, and focus indicators 3:1.
- Targets at least 24 by 24 CSS pixels, or spaced so they are.
- Modal dialogs (`role="dialog"`, `aria-modal`, labelled by their title) keep Tab inside, close on Escape, and return focus to the opener. Menus do not trap: Tab closes them, Escape closes and returns focus. When a focused element is removed, focus moves to a sensible neighbor, never to `body`.
- Status messages (saved, failed, loading, result counts) use `role="status"` or `role="alert"` and do not take focus. Moving focus is a change of context, reserved for navigation.
- Changing a control never auto-submits or navigates. Actions complete on the up event. Every drag has a single-pointer alternative.
- Content shown on hover or focus is dismissible with Escape, hoverable, and stays until dismissed.
- Nothing flashes more than three times a second. Auto-playing motion longer than five seconds can be paused. Interaction motion respects `prefers-reduced-motion`.
- Text resizes to 200 percent and reflows at 320 CSS pixels without loss of content or two-dimensional scrolling.
- Errors identify the field, describe the problem in text, and suggest the fix when known.
- Never ask for data already entered in the same flow. Login never requires a puzzle or transcription and never blocks paste or password managers.
- `<html lang>`. The document title changes per SPA view. Headings and labels describe their purpose. A skip link or landmarks lead to the main content.
