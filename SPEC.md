# Project specification

## Problem

Setting up opencode with a working model stack, plugins, routing, skills, and
token-saving tooling is a long, error-prone manual process that breaks silently
when model IDs or plugin APIs change. omochi is a portable, AI-driven setup
that installs and re-runs itself.

## Users

- Primary users: a CachyOS (Arch) workstation with the fish shell, and a
  Windows 11 workstation with PowerShell (via `setup.ps1`).
- Secondary users: anyone cloning the repo who wants the same opencode setup.

## Required behavior

- `setup.sh` bootstraps opencode, bun, and rtk, clones the repo into
  `~/omochi`, and installs the repo's skills, templates, global `AGENTS.md`,
  and rtk plugin — idempotent, with `--dry-run`, `--repo <url>`, and backup of
  any `~/omochi` or managed file it replaces.
- `setup.ps1` mirrors the bootstrap on Windows (PowerShell 5.1+): opencode 2.0
  via npm (`@opencode/cli`) or the standalone zip, bun via the official
  installer, rtk via winget or the prebuilt binary — same `-DryRun`/`-Repo`
  options, backups, and idempotency as `setup.sh`.
- `opencode-setup-prompt.md` is an AI-driven setup prompt that discovers live
  models, writes OpenCode 2.0 native configs, configures rtk, verifies the
  installed files, and runs smoke tests. Re-running it is the auto-update path.
- Configs must not contain hardcoded model IDs; committed references are role
  placeholders (`<main>`, `<worker>`, `<planner>`) or documented fallback
  examples.
- Skills follow the opencode skill format (front matter `name`/`description`,
  name matching its directory).
- `./scripts/validate.sh` gates the repository: required files, plugin
  manifest, skill front matter and docs sync, template placeholders, Bash
  syntax, ShellCheck, PowerShell parse checks, and no tracked credentials or
  runtime files.
- `./scripts/test-install.sh` verifies `setup.sh` in an isolated environment;
  `./scripts/test-install.ps1` verifies `setup.ps1` the same way on Windows.
- CI runs validation on every push and pull request, on Linux and Windows.

## User experience

- Fresh machine: one bootstrap command (curl `setup.sh` on Linux, irm
  `setup.ps1` on Windows), one manual auth step (`opencode auth login`; the
  `OPENCODE_API_KEY` env var is optional), then one `opencode run` command to
  complete the setup.
- Updates: re-run the setup prompt; the diff review shows exactly what
  changed.
- Failures degrade: free fallback models keep working while provider billing
  is resolved; rtk disables itself when missing.

## Architecture and data flow

- `setup.sh` -> bootstrap binaries + repo clone + skills, templates, global
  `AGENTS.md`, and `plugins/rtk.ts` installed into their opencode paths.
- `setup.ps1` -> the same bootstrap on Windows (opencode 2.0 via npm or the
  standalone zip, rtk via winget or the prebuilt binary); `test-install.ps1`
  and `smoke.ps1` cover it.
- `opencode-setup-prompt.md` -> executed by opencode -> writes
  `~/.config/opencode/opencode.jsonc`, configures rtk (Linux:
  `~/.config/rtk/config.toml`; Windows: `%APPDATA%\rtk\config.toml`), verifies
  the installed files, runs smoke tests.
- `templates/global-AGENTS.md` -> `~/.config/opencode/AGENTS.md`.
- `templates/project-docs/` -> `~/.config/opencode/templates/project-docs/`.
- `plugins/rtk.ts` -> `~/.config/opencode/plugins/rtk.ts`.
- `.agents/skills/` -> `~/.agents/skills/` (installed by `setup.sh`).
- `opencode-plugins.txt` -> the `plugins` array in opencode.jsonc.
- OpenCode 2.0 native features handle multi-agent routing, git worktrees, and
  context compaction without brittle third-party framework layers.
- The setup prompt adds remote `instructions`
  (opencode-shell-strategy, non-interactive shell rules) and configures
  plannotator (`@plannotator/opencode`) for visual plan review.

## Security and privacy

- Never commit credentials, tokens, API keys, `auth.json`, `fish_variables`,
  or `.env` files; `.gitignore` and `validate.sh` enforce this.
- API keys enter only through `{env:VAR}` references or interactive
  `opencode auth login`.
- The fetch MCP selection avoids the known honeypot package
  (`mcp-server-fetch`); traps are documented in the setup prompt.

## Performance and compatibility

- Supported: Linux (primary target CachyOS/Arch, fish shell; bash for
  scripts) and Windows 10/11 (PowerShell 5.1+; `setup.ps1` and
  `scripts/*.ps1`), opencode 2.0.
- Scripts are POSIX-bash with `bash -n`/ShellCheck clean; PowerShell scripts
  are parse-checked by `validate.sh` when a PowerShell host is available.
- No network calls during validation except CI checkout.

## Non-goals

- Distribution: no npm package, plugin manifest, or marketplace catalog.
  omochi is a personal setup repo — clone it and run the setup script.
- Managing other editors or agents (Codex, Claude Code).
- Hardcoding or pinning model IDs in committed configs.
- Bloating the setup with heavy third-party agent framework layers.

## Acceptance criteria

- `./scripts/validate.sh` exits 0 on a clean tree.
- `./scripts/test-install.sh` passes: install, backup, idempotency, and
  dry-run behaviors.
- `./scripts/test-install.ps1` passes the same checks for `setup.ps1` on
  Windows.
- `./scripts/smoke.sh` exits 0 when the rtk plugin rewrites a bash command
  (manual; needs a logged-in provider); `smoke.ps1` is the Windows variant.
- CI runs the gate and the installer tests on push and pull request.
- A fresh bootstrap plus the setup prompt produces a working opencode with
  discovered model IDs and passing smoke tests.

## Unresolved questions

- None blocking; model selections change at runtime by design.
