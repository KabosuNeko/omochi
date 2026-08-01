#!/usr/bin/env bash
set -euo pipefail
# ai-setup bootstrap: install opencode + bun, fetch this repo.
# Everything else (configs, OMO, skills, model discovery) is done by the
# AI-driven setup prompt — run it AFTER the manual steps below.

REPO_URL="${AI_SETUP_REPO_URL:-https://github.com/KabosuNeko/omochi}"

[ -x /usr/bin/opencode ] || {
  echo ">> Installing opencode (pacman)..." \
  && sudo pacman -S --noconfirm opencode \
  || { echo ">> pacman failed, trying official installer..."; curl -fsSL https://opencode.ai/install | bash; }
}

[ -x /usr/bin/bun ] || {
  echo ">> Installing bun (pacman)..."
  sudo pacman -S --noconfirm bun
}

[ -d "$HOME/omochi" ] || {
  echo ">> Cloning omochi into ~/omochi"
  git clone --depth 1 "$REPO_URL" "$HOME/omochi"
}

cat <<'EOF'

Bootstrap done. Manual steps (interactive / secret, cannot be automated):

  1. opencode auth login            # select opencode-go (and OpenCode Zen for free models)
  2. set -Ux OPENCODE_API_KEY "sk-..."   # fish; opencode-go token from your workspace
  3. opencode run "$(cat ~/omochi/opencode-setup-prompt.md)"
                                    # AI-driven setup: discovers models, writes configs,
                                    # installs OMO, provisions skills/templates, smoke tests

EOF
