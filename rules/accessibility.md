---
paths:
  - "**/*.{tsx,jsx,html,vue,svelte,astro}"
---

# Accessibility

Target WCAG 2.2 AA. Every item below is checkable in the diff.

- Semantic elements before ARIA. `button`, `a`, `nav`, `main`, `label`, `table` before `div` with a role. ARIA only when no native element carries the meaning.
- Every interactive element is reachable and operable by keyboard, in a sensible order, with a visible focus state. Nothing responds only to hover or pointer.
- Every input has a programmatic label. Placeholder is not a label.
- Every image has `alt`; decorative images have `alt=""`.
- Color never carries meaning alone. Text contrast at least 4.5:1, large text and UI parts 3:1.
- Targets at least 24 by 24 CSS pixels, or spaced so they are.
- Dialogs, drawers, and menus trap focus while open and return it on close. Route changes move focus to the new content.
- Async status (loading, saved, failed) is announced: a live region or focus moved to the message, not a visual-only spinner.
- Motion respects `prefers-reduced-motion`. Nothing flashes.
- Text resizes to 200 percent without loss of content or function.
- Errors name the field and how to fix it, adjacent to the field, not only at the top.
