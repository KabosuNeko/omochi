# Repository instructions

## Scope

This repository is the source of truth for the omochi opencode setup: portable
configuration, reusable skills, and an AI-driven setup prompt. The root
`AGENTS.md` is the project maintenance file for tools that load it
automatically.

## Operating principles

- Working code and working config only. Plausibility is not correctness;
  verify before reporting done.
- Never fabricate file paths, model IDs, command output, or test results. Read
  the file, run the command, or say what is unknown.
- Say when a premise appears wrong before implementing around it.
- Ask before proceeding only when a request has multiple plausible
  interpretations and the choice materially affects the result.
- Touch only what the task requires. Avoid drive-by refactors, formatting, or
  cleanup.
- Keep communication direct and concise. Skip flattery, filler, ceremonial
  openings, and emoji.

## Command execution

- Use raw commands when output matters: inspecting files, validating exact
  stdout/stderr, checking exit status, or model discovery.
- Use `rtk` for noisy validation commands (test suites, builds, broad
  searches) only when a filtered summary is sufficient. If `rtk` hides needed
  detail, rerun raw immediately.
- Prefer running code, tests, and linters over guessing.
- Read complete errors, logs, and stack traces before fixing them.

## Before editing

- State the plan or success criteria before editing. For non-trivial work,
  include the verification you expect to run.
- Read the files you will touch and the nearby consumers that define their
  behavior.
- Match existing project patterns, naming, and style.
- Surface assumptions out loud when they affect the result.

## Editing

- Use simple ASCII punctuation unless a file format requires otherwise.
- Never commit credentials, tokens, API keys, `auth.json`, `fish_variables`,
  or `.env` files. Use `{env:VAR}` references or `auth.json` only.
- Do not hardcode model IDs in committed files. The setup prompt discovers
  models at runtime; committed references must stay as role placeholders
  (`<main>`, `<worker>`, `<planner>`) or documented fallback examples.
- Put reusable workflows in `.agents/skills/<name>/SKILL.md`.
- Put portable templates in `templates/`.
- Put reference documentation in `docs/`; load it only when needed.
- Do not add speculative features, abstractions, configurability, or hooks.
- Do not create skills that duplicate OMO built-ins (git-master, playwright,
  frontend-ui-ux, review-work, remove-ai-slops).
- Clean up orphans created by your own change.

## Documentation routing

Read only the documents needed for the task:

- `SPEC.md` for product requirements, boundaries, and acceptance criteria.
- `ROADMAP.md` for ordered outcomes, risks, and phase exit criteria.
- `TASKS.md` for the current phase, validation status, and remaining work.
- `docs/SKILLS.md` when creating or changing skills.
- `docs/LAYOUT.md` for discovery and installation boundaries.
- `docs/WORKFLOW.md` when changing the setup workflow or this prompt.

## Verification

- Run the smallest meaningful verification during iteration and the complete
  gate before reporting done.
- If verification fails, fix the cause instead of weakening the check.
- Run `./scripts/validate.sh` after changing configuration, skills, install
  scripts, templates, docs, or repository layout.
- Run `./scripts/test-install.sh` directly when diagnosing `setup.sh`
  behavior.

## Maintenance

- Keep this file short enough to follow. Add rules only when they prevent a
  real repeat mistake or document durable project behavior.
- When the user corrects an approach, tighten the relevant rule instead of
  appending a vague warning.
