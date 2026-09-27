---
name: explain
description: Explains how code in this repo works, with a diagram and a path:line walk-through. Use when the user asks how a part of this codebase works. Not for library, platform, or Claude Code questions.
---

Answer in the first sentence: what the code does and why it exists.

Then, only the parts that apply:

1. Diagram: the flow or structure in a `text` fenced block, when three or more parts interact.
2. Walk-through: execution order, one line per step, each citing `path:line`.
3. Gotcha: the one thing a reader is most likely to get wrong here.

Read the code before explaining it; never describe a file you have not opened. One analogy only when the concept has no counterpart elsewhere in this codebase. No headings, no bold.
