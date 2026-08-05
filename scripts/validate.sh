#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0

fail() {
  printf 'error: %s\n' "$1" >&2
  errors=$((errors + 1))
}

required_files=(
  "AGENTS.md"
  "README.md"
  "opencode-setup-prompt.md"
  "setup.sh"
  ".gitignore"
  "opencode-plugins.txt"
  ".rtk/filters.toml"
  "docs/LAYOUT.md"
  "docs/SKILLS.md"
  "docs/WORKFLOW.md"
  "templates/global-AGENTS.md"
  "templates/omo-routing.jsonc"
  "templates/project-docs/AGENTS.md"
  "templates/project-docs/ROADMAP.md"
  "templates/project-docs/SPEC.md"
  "templates/project-docs/TASKS.md"
)

for relative in "${required_files[@]}"; do
  [[ -f "$repo_root/$relative" ]] || fail "missing $relative"
done

# ---- opencode-plugins.txt manifest ------------------------------------------

plugin_manifest="$repo_root/opencode-plugins.txt"
[[ -s "$plugin_manifest" ]] || fail "opencode-plugins.txt contains no plugins"

plugin_re='^(@[a-z0-9][a-z0-9._-]*/)?[a-z0-9][a-z0-9._-]*(@[a-z0-9._-]+)?$'
while IFS= read -r plugin || [[ -n "$plugin" ]]; do
  [[ -n "$plugin" ]] || continue
  [[ "$plugin" == '#'* ]] && continue
  [[ "$plugin" =~ $plugin_re ]] || fail "opencode-plugins.txt contains an invalid plugin selector: $plugin"
done <"$plugin_manifest"

duplicate_plugins="$(sort "$plugin_manifest" | uniq -d)"
[[ -z "$duplicate_plugins" ]] || fail "opencode-plugins.txt contains duplicate plugins"

while IFS= read -r plugin || [[ -n "$plugin" ]]; do
  [[ -n "$plugin" ]] || continue
  [[ "$plugin" == '#'* ]] && continue
  grep -Fq "\"$plugin@latest\"" "$repo_root/opencode-setup-prompt.md" \
    || grep -Fq "\"$plugin\"" "$repo_root/opencode-setup-prompt.md" \
    || fail "opencode-plugins.txt entry missing from opencode-setup-prompt.md: $plugin"
done <"$plugin_manifest"

# ---- skills -----------------------------------------------------------------

skill_count=0
actual_skills=""
for skill_dir in "$repo_root"/.agents/skills/*; do
  [[ -d "$skill_dir" ]] || continue
  skill_count=$((skill_count + 1))
  skill_file="$skill_dir/SKILL.md"
  skill_basename="$(basename "$skill_dir")"

  if [[ ! -f "$skill_file" ]]; then
    fail "missing ${skill_file#"$repo_root"/}"
    continue
  fi

  first_line="$(sed -n '1p' "$skill_file")"
  [[ "$first_line" == "---" ]] || fail "${skill_file#"$repo_root"/} has no YAML front matter"
  grep -q '^name: .\+' "$skill_file" || fail "${skill_file#"$repo_root"/} has no name"
  grep -q '^description: .\+' "$skill_file" || fail "${skill_file#"$repo_root"/} has no description"
  skill_name="$(sed -n 's/^name: //p' "$skill_file" | sed -n '1p')"
  [[ "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] ||
    fail "${skill_file#"$repo_root"/} has an invalid skill name"
  [[ "$skill_name" == "$skill_basename" ]] ||
    fail "${skill_file#"$repo_root"/} name does not match its directory"
  ! grep -q '\[TODO:' "$skill_file" || fail "${skill_file#"$repo_root"/} contains TODO placeholders"
  ! grep -Eiq '(deepseek|qwen|glm-|kimi|gpt-[0-9]|claude|gemini|opencode-go/)' "$skill_file" ||
    fail "${skill_file#"$repo_root"/} hardcodes a model ID"
  ! grep -qi 'codex' "$skill_file" ||
    fail "${skill_file#"$repo_root"/} references a non-opencode tool"
  actual_skills+="$skill_basename"$'\n'
done

[[ $skill_count -gt 0 ]] || fail "no skills found under .agents/skills"

# shellcheck disable=SC2016
documented_skills="$(
  sed -n '/^## Repository skills$/,/^## /p' "$repo_root/docs/SKILLS.md" |
    sed -n 's/^- `\([^`]*\)`$/\1/p' |
    sort
)"
actual_skills="$(printf '%s' "$actual_skills" | sort)"
[[ "$documented_skills" == "$actual_skills" ]] ||
  fail "docs/SKILLS.md does not match .agents/skills"

# ---- templates --------------------------------------------------------------

[[ -s "$repo_root/templates/global-AGENTS.md" ]] || fail "templates/global-AGENTS.md is empty"
[[ -s "$repo_root/templates/omo-routing.jsonc" ]] || fail "templates/omo-routing.jsonc is empty"
grep -q '"\[opencode\]"' "$repo_root/templates/omo-routing.jsonc" ||
  fail "templates/omo-routing.jsonc has no [opencode] block"
grep -q '"<main>"' "$repo_root/templates/omo-routing.jsonc" ||
  fail "templates/omo-routing.jsonc lacks the <main> placeholder"
grep -q '"<worker>"' "$repo_root/templates/omo-routing.jsonc" ||
  fail "templates/omo-routing.jsonc lacks the <worker> placeholder"
grep -q '"<planner>"' "$repo_root/templates/omo-routing.jsonc" ||
  fail "templates/omo-routing.jsonc lacks the <planner> placeholder"

# ---- bash scripts -----------------------------------------------------------

if ! bash -n "$repo_root/setup.sh" "$repo_root/scripts/validate.sh"; then
  fail "Bash syntax validation failed"
fi

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$repo_root/setup.sh" "$repo_root/scripts/validate.sh" ||
    fail "ShellCheck failed"
fi

# ---- secrets / runtime files ------------------------------------------------

for forbidden in auth.json fish_variables .env snapshot opencode.db; do
  [[ ! -e "$repo_root/$forbidden" ]] || fail "runtime or credential file must not be tracked: $forbidden"
done

if command -v git >/dev/null 2>&1 &&
  git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tracked="$(git -C "$repo_root" ls-files)"
  if grep -qE '(^|/)(auth\.json|fish_variables|\.env(\.|$)|.*\.(key|pem)|opencode\.db)$' <<<"$tracked"; then
    fail "tracked credential or runtime files detected"
  fi
  # Fragment the pattern so validate.sh does not match its own source.
  secret_prefix='sk-'
  key_pattern="${secret_prefix}ant-|${secret_prefix}[A-Za-z0-9]{40,}"
  if git -C "$repo_root" grep -nIE "$key_pattern" >/dev/null 2>&1; then
    fail "tracked API key pattern detected"
  fi
fi

if [[ $errors -gt 0 ]]; then
  printf 'validation failed with %d error(s)\n' "$errors" >&2
  exit 1
fi

printf 'validation passed: %d skills checked\n' "$skill_count"