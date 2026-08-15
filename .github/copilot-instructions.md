---
label: GitHub Copilot Repository Adapter
version: 1.0.0
---

# GitHub Copilot Repository Adapter

Use `REPOSITORY_CONTEXT.md` as the canonical source for repository-wide
context, ownership boundaries, modification invariants, security constraints,
and validation guidance.

Use `README.md` for operator-oriented workflows and usage.

Before proposing or making a change:

1. Read the relevant repository context and operator workflow.
2. Inspect the script or configuration that owns the requested behavior.
3. Keep the change scoped to the request and avoid unrelated cleanup.

Scripts and configuration are authoritative for exact current behavior. If
descriptive documentation differs from implementation, report the discrepancy
rather than silently resolving it, replacing it, or inventing behavior.

Files under `.github/instructions/*.instructions.md` apply only when their
frontmatter `applyTo` scope matches a file being changed. They are path-scoped
guidance, not independent repository architecture.
