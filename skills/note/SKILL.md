---
name: note
description: Save one durable fact about this repo to its context file. Manual only.
disable-model-invocation: true
argument-hint: <the fact>
allowed-tools: Read Edit Write Bash(basename *) Bash(echo *)
---

Context file: !`echo "$HOME/.claude/context/$(basename "$CLAUDE_PROJECT_DIR").md"`

Append this as one line under `## Notes` in the context file, reworded only for brevity, nothing added:

$ARGUMENTS

If the file does not exist, create it with `# <repo>` and the `## Notes` heading. If the heading is missing, add it at the end. Then reply with the line you wrote and stop.
