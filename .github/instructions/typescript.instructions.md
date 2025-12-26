---
applyTo: "**/*.{ts,tsx}"
---

# TypeScript Instructions

## Design & Architecture

* Prefer small, composable modules; avoid “god” utilities and tightly coupled helpers.
* Keep data fetching / I/O separate from pure transformation logic.
* Avoid unnecessary abstractions; introduce them only when they remove duplication across callers.

## “Good” Typing

* Prefer `unknown` over `any`; narrow with type guards before use.
* Prefer unions, `Readonly`, and generics over broad object shapes.
* Avoid type assertions (`as X`) unless you can prove correctness; prefer validation / narrowing.
* Export types intentionally: keep internal types unexported unless used across module boundaries.

Example: `unknown` + narrowing (good boundary hygiene)

```tsx
type MetricPoint = {
  metricId: string;
  timestamp: string; // ISO8601
  value: number;
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

export function parseMetricPoints(rows: unknown[]): MetricPoint[] {
  return rows.map((row) => {
    if (!isRecord(row)) {
      throw new Error("row must be an object");
    }

    const metricId = row["metricId"];
    const timestamp = row["timestamp"];
    const value = row["value"];

    // Fail fast at the boundary: downstream code assumes these invariants.
    if (typeof metricId !== "string" || metricId.length === 0) {
      throw new Error("row.metricId must be a non-empty string");
    }
    if (typeof timestamp !== "string" || timestamp.length === 0) {
      throw new Error("row.timestamp must be a non-empty string (ISO8601)");
    }
    if (typeof value !== "number" || Number.isNaN(value)) {
      throw new Error("row.value must be a number");
    }

    return { metricId, timestamp, value };
  });
}
```

### Commenting Rules (Mandatory When…)

Add comments when any of the following are true:

* A block enforces a non-obvious invariant or contract.
* A transformation is lossy/opinionated (normalization, coercion, fallback behavior).
* A decision exists for performance, security, or external integration constraints.

Do NOT comment:

* Obvious control flow (map, filter, if)
* Restatements of types or names
* Anything that can be expressed via better naming

### Bad vs Good comment micro-examples

```tsx
// BAD: narrates the obvious
// filter out nulls
const ids = values.filter((v) => v !== null);

// GOOD: explains why the policy exists
// We drop null ids because the downstream API rejects them with 400s.
const ids = values.filter((v) => v !== null);
```

## Code Style Conventions

* Prefer const; use let only when reassignment is required.
* Use early returns to reduce nesting.
* Prefer named exports.
* Avoid default exports unless the repo consistently uses them for components/pages.

React (TSX) Expectations

* Prefer function components with typed props.
* Keep components pure; move side-effects into hooks (useEffect) with correct dependency arrays.
* Avoid inline complex logic in JSX; extract helpers or subcomponents.

Example: typed props + extracted logic

```tsx
type NavigationAnchor = Readonly<{
  label: string;
  href: string;
}>;

type WelcomeHeroProps = Readonly<{
  title: string;
  anchors: readonly NavigationAnchor[];
}>;

function formatAnchorLabel(label: string): string {
  return label.trim();
}

export function WelcomeHero({ title, anchors }: WelcomeHeroProps) {
  return (
    <header>
      <h1>{title}</h1>
      <nav aria-label="On this page">
        <ul>
          {anchors.map((a) => (
            <li key={a.href}>
              <a href={a.href}>{formatAnchorLabel(a.label)}</a>
            </li>
          ))}
        </ul>
      </nav>
    </header>
  );
}
```

## Error Handling

* Throw Error with actionable messages; include context but avoid leaking secrets.
* Prefer returning typed results over throwing for expected control flow (e.g., parse functions may throw; business logic should usually return Result-like types if failures are expected).

Example: Result type for expected failures

```tsx
export type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: string };

export function parsePort(value: string): Result<number> {
  const n = Number(value);
  if (!Number.isInteger(n) || n < 1 || n > 65535) {
    return { ok: false, error: "port must be an integer in [1, 65535]" };
  }
  return { ok: true, value: n };
}
```

## Testing Expectations

Prefer fast unit tests for pure logic; avoid tests that depend on time, network, or randomness.
Test behavior, not implementation details.

Example: behavior-focused tests (Vitest/Jest style)

```tsx
import { describe, expect, it } from "vitest";
import { parsePort } from "./parsePort";

describe("parsePort", () => {
  it("rejects out-of-range ports", () => {
    expect(parsePort("70000")).toEqual({ ok: false, error: expect.stringContaining("port") });
  });

  it("accepts valid ports", () => {
    expect(parsePort("8080")).toEqual({ ok: true, value: 8080 });
  });
});
```

## Tooling Awareness

* Assume formatting/linting/typecheck are enforced in CI.
* If a construct may fail linting or type checks, adjust the implementation—not the tool.
* When uncertain, inspect repo configs (e.g., tsconfig.json, .eslintrc*, package.json scripts).

### Output Rules

* Generate production-ready TypeScript by default.
* Do not include commented-out code or exploratory snippets.
* If a decision is non-obvious, add a short comment explaining why.

### Golden Rule

If a future engineer would reasonably ask “why is this here?”, add a short comment answering that question.
