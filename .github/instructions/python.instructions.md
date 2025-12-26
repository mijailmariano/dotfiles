---
applyTo: "**/*.py"
---

# Python Instructions

## Design & Architecture
* Prefer small, single-purpose functions and classes with explicit responsibilities.
* Favor composition over inheritance; avoid deep class hierarchies.
* Keep domain logic pure and isolated from I/O, framework, or orchestration code.
* Make invariants explicit at boundaries (validate inputs early, fail fast).

## Commenting Rules (Mandatory When…)

Add comments when **any** of the following are true:
* A loop or block enforces a non-obvious invariant.
* Validation logic exists to protect downstream assumptions.
* A transformation is lossy, opinionated, or irreversible.
* Behavior is constrained by an external system, contract, or performance concern.

Do NOT comment:
* Obvious control flow (`for`, `if`, `append`)
* What is already clear from naming and types
* Implementation details that restate the code

Notes:
* Prefer self-explanatory code; comment **why**, not **what**.
* Use comments to document constraints, invariants, surprising behavior, or non-obvious trade-offs.
* Avoid commented-out code; remove it.
* Use `TODO:` only for known follow-ups that do not compromise correctness.

### "Bad vs Good" comment micro-examples

#### Loop Commenting: Bad vs Good

```py
# BAD: explains mechanics
for row in rows:
    # get the value
    value = row["value"]

# GOOD: explains intent / constraint
for row in rows:
    # Each row is validated independently so a single bad record
    # does not corrupt the entire batch.
    value = row["value"]
```


#### "Bad vs Good" comment example case

```py
# BAD: narrates the obvious
# increment i by 1
i += 1

# GOOD: explains why this is necessary
# We normalize to UTC here because downstream aggregation assumes UTC timestamps.
timestamp = timestamp.astimezone(timezone.utc)
```

## “Good” Type Hints
* Use type hints everywhere; avoid `Any` unless strictly necessary and documented.
* Prefer precise container types (`Sequence`, `Mapping`) over concrete types when possible.
* Prefer `| None` / `Optional[T]` over sentinel values.
* If a value is constrained, model it (e.g., `Literal`, `Enum`, small value object) instead of loose strings.

## Docstrings & Public Interfaces

* Add docstrings for public functions/classes and anything non-obvious.
* Docstrings should state: purpose, inputs/outputs, key invariants, and raised exceptions (if important).

### Example: concise docstring that helps future changes

```py
def compute_percentiles(values: Sequence[float], percentiles: Sequence[int]) -> dict[int, float]:
    """Compute selected percentiles from a non-empty sequence of floats.

    Args:
        values: Non-empty numeric values.
        percentiles: Integers in [0, 100].

    Returns:
        Mapping percentile -> value.

    Raises:
        ValueError: If values is empty or percentiles are out of range.
    """
    if not values:
        raise ValueError("values must be non-empty")
    for p in percentiles:
        if p < 0 or p > 100:
            raise ValueError(f"percentile out of range: {p}")
    ...
```

### Example: precise types + boundary validation
```py
from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Mapping, Sequence


@dataclass(frozen=True, slots=True)
class MetricPoint:
    metric_id: str
    timestamp: datetime
    value: float


def parse_metric_points(rows: Sequence[Mapping[str, object]]) -> list[MetricPoint]:
    """Parse and normalize raw metric rows into validated MetricPoint objects.

    This function enforces schema correctness and normalizes timestamps to UTC
    to satisfy downstream aggregation assumptions.
    """
    points: list[MetricPoint] = []

    for row in rows:
        # Explicit field extraction makes validation and error reporting clearer
        metric_id = row.get("metric_id")
        ts = row.get("timestamp")
        value = row.get("value")

        # Fail fast at the boundary: downstream code assumes these invariants
        if not isinstance(metric_id, str) or not metric_id:
            raise ValueError("row.metric_id must be a non-empty str")
        if not isinstance(ts, datetime):
            raise ValueError("row.timestamp must be a datetime")
        if not isinstance(value, (int, float)):
            raise ValueError("row.value must be numeric")

        # Normalize timestamps to UTC to ensure consistent aggregation semantics
        points.append(
            MetricPoint(
                metric_id=metric_id,
                timestamp=ts.astimezone(timezone.utc),
                value=float(value),
            )
        )

    return points
```

## Error Handling

* Raise specific exception types; do not swallow exceptions.
* Do not use exceptions for normal control flow.
* Add contextual information when re-raising errors.

### Example: contextual re-raise

```py
class ConfigError(RuntimeError):
    pass


def load_config(path: str) -> dict[str, object]:
    try:
        raw = _read_text_file(path)
        return _parse_yaml(raw)
    except Exception as exc:
        raise ConfigError(f"Failed to load config from {path}") from exc
```

## Style & Readability

* Follow PEP 8 conventions and existing repo formatting.
* Use intention-revealing names; avoid abbreviations and “clever” one-liners.
* Keep functions short; refactor when logic exceeds a single conceptual step.

## Dependencies & Imports

* Prefer standard library solutions before adding new dependencies.
* Do not introduce new dependencies without explicit justification.
* Keep imports ordered; avoid circular dependencies.

## Testing Expectations (What “Good” Looks Like)

* New logic requires unit tests; bug fixes require regression tests.
* Tests must be deterministic and independent of execution order.
* Prefer testing behavior over implementation details.
* Avoid network, filesystem, or time dependencies unless explicitly required.

### Example: behavior-focused unit tests (pytest style)

```py
import pytest

def test_parse_metric_points_rejects_missing_metric_id() -> None:
    with pytest.raises(ValueError, match="metric_id"):
        parse_metric_points([{"timestamp": object(), "value": 1.0}])

def test_parse_metric_points_coerces_numeric_value() -> None:
    ts = datetime(2025, 1, 1, tzinfo=timezone.utc)
    points = parse_metric_points([{"metric_id": "m1", "timestamp": ts, "value": 1}])
    assert points[0].value == 1.0
```

## Performance & Safety

* Avoid unnecessary allocations and repeated work in hot paths.
* Be explicit about algorithmic complexity when non-obvious.
* Validate external data; never trust input shape or types implicitly.

## Tooling Awareness

* Assume linting, formatting, and type-checking are enforced in CI.
* If a construct may fail linting or type checks, adjust the implementation—not the tool.
* When uncertain, inspect repo config files (e.g., `pyproject.toml`, `.flake8`, `mypy.ini`).

## Output Rules

* Generate production-ready code by default.
* Do not include exploratory or commented-out code.
* If a design choice is non-obvious, add a short comment explaining why.

### Golden Rule
If a future engineer would reasonably ask “why is this here?”, add a short comment answering that question.
