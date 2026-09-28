#!/usr/bin/env bash
set -euo pipefail
# Smoke test: prove the opencode bash tool runs rtk-rewritten commands.
# Needs opencode + rtk installed, a logged-in provider, and network access, so
# it is not part of the CI gate. Override the model with OMOCHI_SMOKE_MODEL.

command_under_test="git status --short ."
model="${OMOCHI_SMOKE_MODEL:-opencode/muse-spark-1.3-contributor-free}"

for tool in opencode rtk; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'error: %s not found in PATH\n' "$tool" >&2
    exit 1
  fi
done

log_dir="$(opencode debug paths | awk '$1 == "log" { print $2 }')"
log="$log_dir/opencode.log"
if [[ -z "$log_dir" || ! -f "$log" ]]; then
  printf 'error: opencode log not found (resolved: %s)\n' "$log" >&2
  exit 1
fi

before="$(wc -l <"$log")"
opencode run --auto -m "$model" \
  "Call the bash tool with this command: $command_under_test  Then reply with just: DONE" >/dev/null

new_spawns="$(tail -n "+$((before + 1))" "$log" | grep -a 'message="spawning process"' || true)"
if [[ -z "$new_spawns" ]]; then
  printf 'error: no process was spawned; the model did not call the bash tool\n' >&2
  exit 1
fi

expected="rtk $command_under_test"
if ! grep -qaF "$expected" <<<"$new_spawns"; then
  printf 'error: command was not rewritten; expected %s in the server log\n' "$expected" >&2
  printf '%s\n' "$new_spawns" | tail -3 >&2
  exit 1
fi

printf 'ok: rtk plugin rewrote the command to: %s\n' "$expected"
