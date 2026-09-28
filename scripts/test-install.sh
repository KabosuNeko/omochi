#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
task_test_root="$(mktemp -d "${TMPDIR:-/tmp}/omochi-install-test.XXXXXX")"
fake_bin="$task_test_root/fake bin"
calls_log="$task_test_root/calls.log"

cleanup() {
  if [[ -d "$task_test_root" && "$(basename "$task_test_root")" == omochi-install-test.* ]]; then
    rm -rf -- "$task_test_root"
  fi
}
trap cleanup EXIT

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

mkdir -p "$fake_bin"
for tool in opencode bun rtk; do
  cat >"$fake_bin/$tool" <<EOF
#!/usr/bin/env bash
printf '%s\\n' "\$*" >>"\$OMOCHI_CALLS_LOG"
EOF
  chmod +x "$fake_bin/$tool"
done

# Snapshot the working tree — not just HEAD — so setup.sh is exercised against
# uncommitted changes too. CI checks out the tree, so this matches CI either way.
snapshot="$task_test_root/repo"
mkdir -p "$snapshot"
tar -C "$repo_root" --exclude=./.git -cf - . | tar -C "$snapshot" -xf -
git -C "$snapshot" init -q
git -C "$snapshot" add -A
git -C "$snapshot" -c user.email=test@example.com -c user.name=test commit -qm snapshot
repourl="file://$snapshot"
export OMOCHI_CALLS_LOG="$calls_log"

fresh_home="$task_test_root/fresh home"
mkdir -p "$fresh_home"
HOME="$fresh_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" >/dev/null
[[ -d "$fresh_home/omochi/.git" ]] || fail "installer did not clone the repository"
[[ ! -s "$calls_log" ]] || fail "installer invoked tools that were already installed: $(cat "$calls_log")"
printf 'ok: already-installed path skips installs and clones\n'

repo_skill_count="$(find "$repo_root/.agents/skills" -name SKILL.md | wc -l | tr -d ' ')"
installed_skill_count="$(find "$fresh_home/.agents/skills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
[[ "$installed_skill_count" -eq "$repo_skill_count" ]] ||
  fail "installer installed $installed_skill_count skills, repository has $repo_skill_count"
printf 'ok: skills installed into ~/.agents/skills\n'

[[ -f "$fresh_home/.config/opencode/plugins/rtk.ts" ]] ||
  fail "installer did not install the rtk plugin"
cmp -s "$repo_root/plugins/rtk.ts" "$fresh_home/.config/opencode/plugins/rtk.ts" ||
  fail "installed rtk plugin differs from the repository copy"
cmp -s "$repo_root/templates/global-AGENTS.md" "$fresh_home/.config/opencode/AGENTS.md" ||
  fail "installed global AGENTS.md differs from the template"
[[ -f "$fresh_home/.config/opencode/templates/project-docs/SPEC.md" ]] ||
  fail "installer did not install the project-docs templates"
printf 'ok: plugin, global AGENTS.md, and templates installed\n'

fresh_home="$task_test_root/idempotent home"
mkdir -p "$fresh_home"
HOME="$fresh_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" >/dev/null
HOME="$fresh_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" >/dev/null
[[ "$(find "$fresh_home/.agents/skills" -name SKILL.md | wc -l | tr -d ' ')" -eq "$repo_skill_count" ]] ||
  fail "re-running the installer changed the installed skill count"
shopt -s nullglob
agents_backups=("$fresh_home/.config/opencode/AGENTS.md.bak-"*)
shopt -u nullglob
[[ ${#agents_backups[@]} -eq 0 ]] ||
  fail "re-running the installer backed up an unchanged AGENTS.md"
printf 'ok: re-running the installer keeps the skill set\n'

dirty_home="$task_test_root/dirty home"
mkdir -p "$dirty_home/omochi" "$dirty_home/.config/opencode"
printf 'user data' >"$dirty_home/omochi/marker.txt"
printf 'local edit' >"$dirty_home/.config/opencode/AGENTS.md"
HOME="$dirty_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" >/dev/null

shopt -s nullglob
backups=("$dirty_home"/omochi.bak-[0-9]*)
shopt -u nullglob
[[ ${#backups[@]} -eq 1 ]] ||
  fail "expected one backup of existing ~/omochi, found ${#backups[@]}"
[[ "$(cat "${backups[0]}/marker.txt")" == "user data" ]] ||
  fail "backup did not preserve the existing ~/omochi content"
[[ -d "$dirty_home/omochi/.git" ]] || fail "installer did not clone after backup"
printf 'ok: dirty ~/omochi is backed up then replaced\n'

shopt -s nullglob
agents_backups=("$dirty_home/.config/opencode/AGENTS.md.bak-"*)
shopt -u nullglob
[[ ${#agents_backups[@]} -eq 1 ]] || fail "expected one backup of a locally edited AGENTS.md"
[[ "$(cat "${agents_backups[0]}")" == "local edit" ]] ||
  fail "AGENTS.md backup did not preserve the local edit"
cmp -s "$repo_root/templates/global-AGENTS.md" "$dirty_home/.config/opencode/AGENTS.md" ||
  fail "AGENTS.md was not replaced with the template"
printf 'ok: a locally edited AGENTS.md is backed up then replaced\n'

dry_home="$task_test_root/dry home"
mkdir -p "$dry_home"
HOME="$dry_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" --dry-run >/dev/null
[[ ! -e "$dry_home/omochi" && ! -L "$dry_home/omochi" ]] ||
  fail "dry run created ~/omochi"
[[ ! -e "$dry_home/.agents" ]] || fail "dry run created ~/.agents"
[[ ! -e "$dry_home/.config/opencode" ]] || fail "dry run wrote to ~/.config/opencode"
printf 'ok: dry run changes nothing\n'

missing_home="$task_test_root/missing tools home"
mkdir -p "$missing_home"
set +e
PATH="/usr/bin:/bin" HOME="$missing_home" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" --dry-run \
  >"$task_test_root/missing-tools.dry-std" 2>"$task_test_root/missing-tools.dry-err"
dry_status=$?
set -e
[[ $dry_status -eq 0 ]] || fail "dry run with missing tools exited $dry_status"
[[ ! -e "$missing_home/omochi" && ! -L "$missing_home/omochi" ]] ||
  fail "dry run with missing tools created ~/omochi"
! grep -q 'command not found' "$task_test_root/missing-tools.dry-err" ||
  fail "dry run leaked preview text into a piped shell"
if grep -q 'opencode.ai/install' "$task_test_root/missing-tools.dry-std"; then
  grep -q '| bash$' "$task_test_root/missing-tools.dry-std" ||
    fail "dry run previewed the opencode installer without a terminating pipe target"
fi
if grep -q 'raw.githubusercontent.com/rtk-ai/rtk' "$task_test_root/missing-tools.dry-std"; then
  grep -q '| sh$' "$task_test_root/missing-tools.dry-std" ||
    fail "dry run previewed the rtk installer without a terminating pipe target"
fi
printf 'ok: dry run previews piped installs without leaking into the pipe\n'

printf 'installer integration test passed\n'