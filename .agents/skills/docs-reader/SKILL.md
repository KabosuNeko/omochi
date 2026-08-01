---
name: docs-reader
description: Read and understand project documentation — SPEC, ROADMAP, TASKS, AGENTS.md, README, docs/, and dependency docs (via context7). Produces accurate, cited summaries and answers. Use for "what does this do", "read the docs", onboarding to a new repo, or library research. Delegates to the librarian agent (Kimi K2.7 Code).
compatibility: opencode
---

# Docs Reader

Never answer from memory when docs exist in the repo or upstream.

## Delegation

For docs/code search across the repo or OSS, delegate to the `librarian`
agent via `call_omo_agent` (subagent_type: librarian) — it runs on the
reviewer model and stays current on library APIs.

## Local flow

1. Map the docs: AGENTS.md, SPEC.md, ROADMAP.md, TASKS.md, README.md, then
   `docs/` and in-code comments.
2. For dependency/framework questions, use the `context7` MCP tools to pull
   official docs instead of relying on training data.
3. Cite sources: file:line for repo docs, URL + section for external docs.
4. When writing: answers are grounded — no invented APIs, flags, or version
   numbers. Pin versions exactly as the docs say.

## Output

A short answer for quick questions, or a structured brief (overview, key
concepts, gotchas, references) for onboarding-style requests.
