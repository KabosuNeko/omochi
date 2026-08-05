# omochi layout and discovery

## What opencode loads automatically

| Purpose | Global scope | Project scope |
| --- | --- | --- |
| Instructions | `~/.config/opencode/AGENTS.md` | `AGENTS.md` from the repository root to the working directory |
| Configuration | `~/.config/opencode/opencode.json(c)` | `opencode.json(c)` at or above the working directory |
| Skills | `~/.agents/skills/`, `~/.config/opencode/skills/` | `.agents/skills/`, `.claude/skills/`, `.opencode/skills/` |
| Plugins | `~/.config/opencode/plugins/` | `.opencode/plugins/` |
| Templates | `~/.config/opencode/templates/` | `.opencode/templates/` |

A loaded `AGENTS.md`, a selected skill, or the setup prompt must point opencode
to any documents it needs. Files under `docs/` are references, not automatic
instructions.

## Why this repository is not a home-directory mirror

The active `~/.config/opencode` and `~/.agents` directories mix portable
configuration with private and ephemeral runtime state:

- `auth.json`
- session transcripts and history
- `opencode.db` and its snapshots
- opencode/themes under `~/.local/share/opencode/`
- `~/.cache/opencode/node_modules/` (npm plugin cache)
- `~/.omo/omo.jsonc` (OMO routing with live model IDs)
- `~/.config/rtk/config.toml` (machine-specific exclusions)

Tracking or replacing those files would expose credentials and make the setup
less portable. This repository manages only:

- the setup workflow (`opencode-setup-prompt.md`, `setup.sh`)
- reusable skills (`.agents/skills/`)
- portable templates (`templates/`)
- reference docs (`docs/`)
- an opt-in plugin manifest (`opencode-plugins.txt`)

The setup prompt writes live config (model IDs, plugin array, routing) so
what is committed stays role-based and machine-neutral.

## Setup flow

1. `setup.sh` bootstraps: installs opencode, bun, and rtk; clones this repo
   into `~/omochi`. Use `--dry-run` to preview, `--repo <url>` to override the
   source. Existing `~/omochi` dirs are backed up to `~/omochi.bak-*`.
2. Manual, cannot be automated: `opencode auth login` and the
   `OPENCODE_API_KEY` env var.
3. `opencode run "$(cat ~/omochi/opencode-setup-prompt.md)"` discovers live
   models, writes configs, installs OMO, provisions skills and templates, and
   runs smoke tests. Re-running this prompt is the auto-update path.

## Plugins and MCP servers

opencode loads plugins from the `plugin` array in `opencode.json` (npm
packages, installed by Bun on startup) and from local plugin directories.
`opencode-plugins.txt` lists the maintained npm selection; validate it with
`./scripts/validate.sh`.

Standalone MCP servers such as filesystem, git-mcp, mcp-fetch-server, and the
sequential-thinking server are configured by the setup prompt and run via
`npx -y`. Disabled providers and colliding tools are handled through the OMO
`disabled_mcps` setting.

## Skills

Skills live in `sources`: `.agents/skills/` as a source of truth. The setup
prompt provisions them into `~/.agents/skills/` and
`~/.config/opencode/skills/`. See `docs/SKILLS.md`.

## Direct config use

Do not point `XDG_CONFIG_HOME` or plugin directories at this repository. Use
`setup.sh` for bootstrap and the setup prompt for live configuration; this
repository intentionally separates managed files from runtime data.

## Verification

After a setup, restart opencode and ask:

```text
List the instruction sources and relevant skills active for this repository.
```

The expected instruction order is:

1. `~/.config/opencode/AGENTS.md`
2. the repository root `AGENTS.md`
3. any closer nested `AGENTS.md`

Repository hygiene is checked by `./scripts/validate.sh`; installer behavior by
`./scripts/test-install.sh`; both run in CI.