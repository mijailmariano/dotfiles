# .github/copilot-instructions.md

## Purpose
Help Copilot work effectively in this repository with minimal exploration, minimal CI failures, and production-grade changes.

## Operating Principles
- Prefer existing patterns over introducing new architecture; keep changes small and coherent.
- Do not invent APIs, config keys, file paths, scripts, or dependencies—verify by reading the source.
- When requirements are ambiguous or trade-offs exist, ask a concise clarifying question and propose 1–2 options.
- Optimize for correctness, readability, testability, and maintainability over cleverness.
- Avoid “drive-by refactors”; refactor only when necessary to implement the change safely.

## Where to Look First (to reduce searching)
- Start with `README.md` and `CONTRIBUTING.md` for workflow, tooling, and conventions.
- Prefer repo scripts over ad-hoc commands (e.g., `make`, `task`, `scripts/*`, `package.json` scripts).
- Identify CI expectations by reading `.github/workflows/*` and mirror those checks locally.

## Change Quality Bar
- Code must build, lint, and test locally using the repo’s standard commands.
- Update or add tests for any behavioral change:
  - Bug fix => add a regression test.
  - New logic => add unit tests; add integration tests only at boundaries.
- Keep interfaces explicit; document non-obvious behavior and edge cases near the code.

## Build / Test / Lint Guidance
- Always use the repository’s documented workflow and versions (e.g., tool versions in `.tool-versions`, `.python-version`, `package.json`, `pyproject.toml`).
- Prefer running the same checks CI runs; if uncertain, inspect `.github/workflows/*` to determine the exact commands.
- If a command fails, capture the exact error and fix root cause; avoid “just ignore” workarounds.

## Project Layout Expectations
- Respect directory structure and ownership boundaries (avoid cross-cutting edits without reason).
- Keep configuration changes localized and consistent with existing config style.
- If adding new files, place them where similar files live and follow naming conventions already present.

## Security & Safety Defaults
- Never commit secrets; use environment variables and documented secret management patterns.
- Validate and sanitize external inputs; avoid unsafe deserialization, shell injection, and overly broad permissions.
- Prefer least privilege and secure-by-default settings in examples.

## When Instructions Conflict
- Follow the most specific applicable instructions in `.github/instructions/*.instructions.md` (path-scoped rules) over this file.
- If two instruction sources conflict, choose the option that matches existing code patterns and CI expectations, and note the decision in the PR.

## Exploration Policy (important)
- Trust these instructions first.
- Only search the repo further when:
  - required information is missing here, or
  - the repo’s source/config contradicts these instructions.