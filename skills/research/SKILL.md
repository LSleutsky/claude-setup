---
name: research
description: Verified research on a question, sources fetched and labeled, no synthesis. Manual only.
disable-model-invocation: true
argument-hint: "<the question>"
---

Question: $ARGUMENTS

Invoke the `researcher` subagent with exactly this instruction and nothing else from this session: "Research this question: <question>. Working directory: <cwd>, in case the repo is relevant."

Show its report unedited. Add nothing: no summary, no recommendation, no commentary on the sources. If the user asks a follow-up, run the subagent again with the follow-up; do not answer from memory. Stop.
