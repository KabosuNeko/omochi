# Project specification

## Problem

Setting up opencode with a working model stack, plugins, routing, skills, and
token-saving tooling is a long, error-prone manual process that breaks silently
when model IDs or plugin APIs change. omochi is a portable, AI-driven setup
that installs and re-runs itself.

## Users

- One primary user: a CachyOS (Arch) workstation with the fish shell.
- Secondary users: anyone cloning the repo who wants the same opencode setup.

## Required behavior

- `setup.sh` bootstraps opencode, bun, and rtk, and clones the repo into
  `~/omochi` — idempotent, with `--dry-run`, `--repo <url>`, and backup of any
  existing `~/omochi`.
- `opencode-setup-prompt.md` is an AI-driven setup prompt that discovers live
  models, writes configs, installs oh-my-openagent, provisions skills and
  templates, and runs smoke tests. Re-running it is the auto-update path.
- Configs must not contain hardcoded model IDs; committed references are role
  placeholders (`<main>`, `<worker>`, `<planner>`) or documented fallback
  examples.
- Skills follow the opencode skill format (front matter `name`/`description`,
  name matching its directory).
- `./scripts/validate.sh` gates the repository: required files, plugin
  manifest, skill front matter and docs sync, template placeholders, Bash
  syntax, ShellCheck, and no tracked credentials or runtime files.
- `./scripts/test-install.sh` verifies `setup.sh` in an isolated environment.
- CI runs validation on every push and pull request.

## User experience

- Fresh machine: one bootstrap command, two manual secret steps, then one
  `opencode run` command to complete the setup.
- Updates: re-run the setup prompt; the diff review shows exactly what
  changed.
- Failures degrade: free fallback models keep working while provider billing
  is resolved; rtk disables itself when missing.

## Architecture and data flow

- `setup.sh` -> bootstrap binaries + repo clone.
- `opencode-setup-prompt.md` -> executed by opencode -> writes
  `~/.config/opencode/opencode.jsonc`, `octto.json`, `~/.omo/omo.jsonc` via
  `templates/omo-routing.jsonc`, provisions skills from `.agents/skills/` and
  `templates/`, installs OMO, configures rtk, runs smoke tests.
- `templates/global-AGENTS.md` -> `~/.config/opencode/AGENTS.md`.
- `templates/project-docs/` -> `~/.config/opencode/templates/project-docs/`.
- `.agents/skills/` -> `~/.agents/skills/` and
  `~/.config/opencode/skills/`.
- `opencode-plugins.txt` -> the `plugin` array in opencode.jsonc.
- The setup prompt adds remote `instructions`
  (opencode-shell-strategy, non-interactive shell rules) and resolves DCP
  (`@tarquinen/opencode-dcp`) with a self-created `dcp.jsonc` for context
  pruning.

## Security and privacy

- Never commit credentials, tokens, API keys, `auth.json`, `fish_variables`,
  or `.env` files; `.gitignore` and `validate.sh` enforce this.
- API keys enter only through `{env:VAR}` references or interactive
  `opencode auth login`.
- The fetch MCP selection avoids the known honeypot package
  (`mcp-server-fetch`); traps are documented in the setup prompt.

## Performance and compatibility

- Supported: Linux (primary target CachyOS/Arch, fish shell; bash for
  scripts), opencode 1.x.
- Scripts are POSIX-bash with `bash -n`/ShellCheck clean.
- No network calls during validation except CI checkout.

## Non-goals

- Managing other editors or agents (Codex, Claude Code).
- Hardcoding or pinning model IDs in committed configs.
- Duplicating OMO built-in skills.
- Windows support.

## Acceptance criteria

- `./scripts/validate.sh` exits 0 on a clean tree.
- `./scripts/test-install.sh` passes: install, backup, idempotency, and
  dry-run behaviors.
- CI runs both on push and pull request.
- A fresh bootstrap plus the setup prompt produces a working opencode with
  discovered model IDs and passing smoke tests.

## Unresolved questions

- None blocking; model selections change at runtime by design.
