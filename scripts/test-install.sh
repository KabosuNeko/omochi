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

repourl="file://$repo_root"
export OMOCHI_CALLS_LOG="$calls_log"

fresh_home="$task_test_root/fresh home"
mkdir -p "$fresh_home"
HOME="$fresh_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" >/dev/null
[[ -d "$fresh_home/omochi/.git" ]] || fail "installer did not clone the repository"
[[ ! -s "$calls_log" ]] || fail "installer invoked tools that were already installed: $(cat "$calls_log")"
printf 'ok: already-installed path skips installs and clones\n'

fresh_home="$task_test_root/idempotent home"
mkdir -p "$fresh_home"
HOME="$fresh_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" >/dev/null
HOME="$fresh_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" >/dev/null

dirty_home="$task_test_root/dirty home"
mkdir -p "$dirty_home/omochi"
printf 'user data' >"$dirty_home/omochi/marker.txt"
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

dry_home="$task_test_root/dry home"
mkdir -p "$dry_home"
HOME="$dry_home" PATH="$fake_bin:$PATH" AI_SETUP_REPO_URL="$repourl" \
  bash "$repo_root/setup.sh" --dry-run >/dev/null
[[ ! -e "$dry_home/omochi" && ! -L "$dry_home/omochi" ]] ||
  fail "dry run created ~/omochi"
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