#!/usr/bin/env bash
set -euo pipefail
# omochi bootstrap: install opencode + bun + rtk, fetch this repo, and install
# the repo's skills, templates, global AGENTS.md, and rtk plugin.
# Model discovery, opencode.jsonc, and the rtk config are done by the
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

# Copy a directory tree in place. Stale entries are not pruned; files the repo
# no longer ships stay on the machine until removed by hand.
provision_tree() {
  local src="$1" dst="$2"
  if "$dry_run" || [[ -d "$src" ]]; then
    run mkdir -p "$dst"
    run cp -r "$src/." "$dst/"
  else
    printf 'warning: %s is missing; nothing installed into %s\n' "$src" "$dst" >&2
  fi
}

# Replace a single config file only when its contents differ, keeping a
# timestamped backup so a local edit is never overwritten silently.
provision_file() {
  local src="$1" dst="$2" backup
  if ! "$dry_run" && [[ ! -e "$src" ]]; then
    printf 'warning: %s is missing; %s was not installed\n' "$src" "$dst" >&2
    return
  fi
  if "$dry_run" || [[ ! -e "$dst" ]]; then
    run mkdir -p "$(dirname "$dst")"
    run cp "$src" "$dst"
    return
  fi
  if cmp -s "$src" "$dst"; then
    return 0
  fi
  backup="$dst.bak-$(date +%Y%m%d-%H%M%S)"
  run cp "$dst" "$backup"
  run cp "$src" "$dst"
  printf '>> replaced %s (kept %s; review with: diff %s %s)\n' "$dst" "$backup" "$backup" "$dst"
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
  echo ">> Installing bun..."
  if has_cmd pacman && has_cmd sudo; then
    if ! run sudo pacman -S --noconfirm bun; then
      echo ">> pacman failed, trying official installer..."
      pipe_install bash curl -fsSL https://bun.sh/install
    fi
  else
    pipe_install bash curl -fsSL https://bun.sh/install
  fi
fi

if [[ -x "$HOME/.bun/bin/bun" ]]; then
  run mkdir -p "$HOME/.local/bin"
  run ln -sf "$HOME/.bun/bin/bun" "$HOME/.local/bin/bun"
  run ln -sf "$HOME/.bun/bin/bunx" "$HOME/.local/bin/bunx"
  run ln -sf "$HOME/.bun/bin/bun" "$HOME/.local/bin/node"
  if [[ ! -e "$HOME/.local/bin/npx" || -L "$HOME/.local/bin/npx" ]]; then
    run rm -f "$HOME/.local/bin/npx"
    if ! "$dry_run"; then
      cat << 'EOF' > "$HOME/.local/bin/npx"
#!/usr/bin/env bash
args=()
for arg in "$@"; do
  if [[ "$arg" != "-y" && "$arg" != "--yes" ]]; then
    args+=("$arg")
  fi
done
exec "$HOME/.bun/bin/bunx" "${args[@]}"
EOF
      chmod +x "$HOME/.local/bin/npx"
    else
      printf '+ write %s/npx\n' "$HOME/.local/bin"
    fi
  fi
fi

# rtk (token saver): no pacman package — official installer, idempotent.
# rtk config is provisioned by the AI-driven setup prompt; the plugin is
# installed below with the other managed files.
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

repo="$HOME/omochi"
opencode_dir="$HOME/.config/opencode"

provision_tree "$repo/.agents/skills" "$HOME/.agents/skills"
provision_tree "$repo/templates/project-docs" "$opencode_dir/templates/project-docs"
provision_file "$repo/templates/global-AGENTS.md" "$opencode_dir/AGENTS.md"
provision_file "$repo/plugins/rtk.ts" "$opencode_dir/plugins/rtk.ts"

cat <<'EOF'

Bootstrap done. Manual steps (interactive / secret, cannot be automated):

  1. fish_add_path ~/.local/bin     # fish; ensure rtk is in PATH if not already
  2. opencode auth login            # select opencode-go (and OpenCode Zen for free models)
  3. (optional) set -Ux OPENCODE_API_KEY "sk-..."   # env-based auth only; step 2 already stores the key
  4. opencode run "$(cat ~/omochi/opencode-setup-prompt.md)"
                                    # AI-driven setup: discovers models, writes configs,
                                    # configures rtk, runs smoke tests

Installed from this repo: ~/.agents/skills, ~/.config/opencode/AGENTS.md,
~/.config/opencode/templates/project-docs, ~/.config/opencode/plugins/rtk.ts.
To update them:
  git -C ~/omochi pull && bash ~/omochi/setup.sh
EOF