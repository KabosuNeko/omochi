#!/usr/bin/env bash
set -euo pipefail
# omochi bootstrap: install opencode + bun + rtk, fetch this repo.
# Everything else (configs, OMO, skills, model discovery) is done by the
# AI-driven setup prompt — run it AFTER the manual steps below.

REPO_URL="${AI_SETUP_REPO_URL:-https://github.com/KabosuNeko/omochi}"
dry_run=false

usage() {
  printf 'usage: %s [--dry-run] [--repo <url>]\n' "$0" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
      ;;
    --repo)
      [[ $# -ge 2 ]] || usage
      REPO_URL="$2"
      shift
      ;;
    *)
      usage
      ;;
  esac
  shift
done

run() {
  if "$dry_run"; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

# Piped installs: dry-run must not leak the preview into the receiving shell.
pipe_install() {
  local shell_cmd="$1"
  shift
  if "$dry_run"; then
    printf '+'
    printf ' %q' "$@"
    printf ' | %s\n' "$shell_cmd"
  else
    "$@" | "$shell_cmd"
  fi
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1 || [[ -x "/usr/bin/$1" ]]
}

if ! has_cmd opencode; then
  echo ">> Installing opencode..."
  if has_cmd pacman && has_cmd sudo; then
    if ! run sudo pacman -S --noconfirm opencode; then
      echo ">> pacman failed, trying official installer..."
      pipe_install bash curl -fsSL https://opencode.ai/install
    fi
  else
    pipe_install bash curl -fsSL https://opencode.ai/install
  fi
fi

if ! has_cmd bun; then
  echo ">> Installing bun (pacman)..."
  run sudo pacman -S --noconfirm bun
fi

# rtk (token saver): no pacman package — official installer, idempotent.
# Config + opencode plugin are provisioned by the AI-driven setup prompt.
if ! has_cmd rtk && [[ ! -x "$HOME/.local/bin/rtk" ]]; then
  echo ">> Installing rtk (official installer)..."
  pipe_install sh curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh
fi

if [[ -d "$HOME/omochi/.git" ]]; then
  echo ">> ~/omochi already installed, skipping clone"
elif [[ -d "$HOME/omochi" ]]; then
  backup="$HOME/omochi.bak-$(date +%Y%m%d-%H%M%S)"
  echo ">> Backing up existing ~/omochi -> $backup"
  run mv "$HOME/omochi" "$backup"
  echo ">> Cloning omochi into ~/omochi"
  run git clone --depth 1 "$REPO_URL" "$HOME/omochi"
else
  echo ">> Cloning omochi into ~/omochi"
  run git clone --depth 1 "$REPO_URL" "$HOME/omochi"
fi

cat <<'EOF'

Bootstrap done. Manual steps (interactive / secret, cannot be automated):

  1. opencode auth login            # select opencode-go (and OpenCode Zen for free models)
  2. set -Ux OPENCODE_API_KEY "sk-..."   # fish; opencode-go token from your workspace
  3. opencode run "$(cat ~/omochi/opencode-setup-prompt.md)"
                                    # AI-driven setup: discovers models, writes configs,
                                    # installs OMO, provisions skills/templates, smoke tests
EOF