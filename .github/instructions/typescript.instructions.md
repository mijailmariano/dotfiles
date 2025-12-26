---
applyTo: "**/*.{ts,tsx}"
---

# TypeScript Instructions

## Design & Architecture
- Prefer small, composable modules; avoid “god” utilities and tightly coupled helpers.
- Keep data fetching / I/O separate from pure transformation logic.
- Avoid unnecessary abstractions; introduce them only when they remove duplication across callers.

## “Good” Typing
- Prefer `unknown` over `any`; narrow with type guards before use.
- Prefer unions, `Readonly`, and generics over broad object shapes.
- Avoid type assertions (`as X`) unless you can prove correctness; prefer validation / narrowing.
- Export types intentionally: keep internal types unexported unless used across module boundaries.

### Example: `unknown` + narrowing (good boundary hygiene)
```ts
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
