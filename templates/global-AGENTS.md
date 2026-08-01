# Global instructions (applies to every repo)

## Working style
- Inspect repository instructions (AGENTS.md, SPEC.md, ROADMAP.md, TASKS.md)
  and existing changes before editing.
- Preserve unrelated user changes. Prefer small, reviewable changes with
  relevant validation.
- Use simple ASCII punctuation unless the file format requires otherwise.
- Never expose credentials, tokens, private keys, or secret file contents.
- No destructive operations without explicit authorization.
- Treat explicit user stop points as hard boundaries; stop and wait.
- Skip filler: no flattery, ceremonial openings, or emoji.

## Verification
- Run the smallest meaningful verification during iteration; run the full
  requested check before reporting done. If verification fails, fix the
  cause instead of weakening the check.
- Read complete errors, logs, and stack traces before fixing.
- For UI changes, verify visually (screenshot or rendered output).

## Scope & delegation
- AGENTS.md = durable conventions · skills = reusable workflows ·
  docs/ = references, not automatic instructions.
- Skill routing: code-review/docs-reader -> momus/librarian
  (kimi-k2.7-code) · refactor-human-code -> hephaestus (deepseek-v4-pro) ·
  bug-hunt -> oracle (qwen3.7-max) · light work -> explore (worker model).
- New workflows go to ~/.config/opencode/skills/<name>/SKILL.md.

## Maintenance
- Keep this file short; add a rule only when it prevents a real repeated mistake.
