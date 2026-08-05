# Skills for opencode

## Purpose

A skill is a reusable workflow loaded on demand through opencode's native
`skill` tool. Skills are chosen by matching their `description`, so triggers and
boundaries belong there.

Use a skill for knowledge that is:

- reused across repositories
- independent of one project's requirements
- specific enough to have a reliable trigger
- too detailed for global or repository instructions

## Required layout

Only `SKILL.md` is required. The opencode skill format does not use
`agents/openai.yaml` (that is the Codex layout). Optional `references/` and
`scripts/` subdirectories are supported.

```text
.agents/skills/skill-name/
├── SKILL.md
├── references/   # optional, loaded only when the task needs them
└── scripts/      # optional deterministic automation
```

`SKILL.md` must start with YAML front matter. Only these fields are recognized:

- `name` (required): 1-64 chars, `^[a-z0-9]+(-[a-z0-9]+)*$`, must match the
  directory name
- `description` (required): 1-1024 chars, specific enough to trigger reliably
- `license`, `compatibility`, `metadata`: optional; unknown fields are ignored

## Discovery locations

```text
repo/.agents/skills/<name>/SKILL.md      project agent-compatible
repo/.claude/skills/<name>/SKILL.md      project Claude-compatible
repo/.opencode/skills/<name>/SKILL.md    project config
~/.agents/skills/<name>/SKILL.md         global agent-compatible
~/.config/opencode/skills/<name>/SKILL.md
```

opencode walks from the working directory up to the git worktree root and also
loads global locations. The setup prompt provisions this repository's skills
into `~/.agents/skills/` (guardrails) and `~/.config/opencode/skills/`
(personal skills).

## Authoring rules

- Keep each skill focused on one workflow.
- Put trigger terms and boundaries in the description.
- Write imperative steps with explicit inputs, outputs, and validation.
- Load references only when the task needs them.
- Keep project requirements in project documentation, not reusable skills.
- Provide, review, test, and debug workflows, not vague checklists.
- Do not hardcode model IDs in skills; delegation targets are agent names.
- Do not create skills that duplicate OMO built-ins (git-master, playwright,
  frontend-ui-ux, review-work, remove-ai-slops).

## Repository skills

- `bash-scripting`
- `bug-hunt`
- `code-review`
- `docs-reader`
- `frontend-design`
- `grill-me`
- `linux-sysadmin`
- `python-ai`
- `refactor-human-code`
- `test-writer`

Run `./scripts/validate.sh` after adding or changing a skill. Validation fails
when this list and the skill directories drift apart, when front matter is
malformed, or when a skill hardcodes a model ID.