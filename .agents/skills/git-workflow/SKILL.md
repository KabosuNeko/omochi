---
name: git-workflow
description: Clean version control hygiene, conventional commits, branch management, rebase workflows, and high-signal PR summaries. Use for commit staging, PR drafting, branch rebasing, or conflict resolution.
compatibility: opencode
---

# Git Workflow

Maintain a clean, linear, and informative git history with disciplined commit craftsmanship.

## Principles

1. **Atomic Commits**:
   - Each commit represents a single logical change that passes tests on its own.
   - Separate refactoring from behavior changes; never mix formatting sweeps with feature implementation.
2. **Conventional Commit Format**:
   - Follow standard prefixes:
     - `feat:` New functionality.
     - `fix:` Bug fix.
     - `refactor:` Code change that neither fixes a bug nor adds a feature.
     - `perf:` Performance improvement.
     - `test:` Adding or correcting tests.
     - `docs:` Documentation changes only.
     - `chore:` Tooling, dependency, or configuration updates.
   - Use imperative, present tense ("add feature", not "added feature").
   - Keep the summary line under 72 characters.
3. **Hygiene & Clean Working Trees**:
   - Run `git status` and `git diff --stat` before staging to verify no unintentional files are included.
   - Never commit sensitive files (`.env`, `auth.json`, secret keys, credentials).
   - Never commit build output, generated binaries, or local cache directories.
4. **Pull Request Discipline**:
   - Provide a concise summary: context, exact changes made, and concrete test commands executed.
   - Keep pull requests small and focused for rapid, thorough peer review.

## Verification

- Review staged diff with `git diff --cached` before committing.
- Run project test suite and linters to ensure every commit in the branch builds cleanly.
