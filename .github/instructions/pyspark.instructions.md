---
applyTo: "**/*spark*.py"
---

# Spark / PySpark Instructions

This document complements the repository's general Python guidance with Spark/PySpark-specific rules focused on correctness, determinism, performance, and testability.

## Core Principles

* Prefer DataFrame APIs over RDDs unless there is a clear, documented need.
* Keep transformations deterministic and schema-explicit; avoid silent type coercions.
* Treat Spark jobs as distributed systems: minimize shuffles, avoid wide dependencies, and control cardinality blowups.
* Separate concerns:
  * I/O + session setup
  * transformations (pure-ish)
  * orchestration (job wiring, arguments, outputs)

## Schema & Contracts (Mandatory)

* Always define/validate schemas at boundaries (reads, external inputs, UDF inputs/outputs).
* Prefer `select` with explicit columns over `select("*")` in production pipelines.
* When joining:
  * validate join keys exist and are non-null when required
  * explicitly resolve duplicate column names (avoid accidental overwrites)

### Example: explicit schema + safe select

```py
from pyspark.sql import DataFrame
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, TimestampType, DoubleType

INPUT_SCHEMA = StructType([
    StructField("metric_id", StringType(), nullable=False),
    StructField("timestamp", TimestampType(), nullable=False),
    StructField("value", DoubleType(), nullable=True),
])

def normalize_metrics(df: DataFrame) -> DataFrame:
    """Normalize raw metrics into a stable contract for downstream consumers."""
    # Fail fast: downstream aggregations assume these columns and types.
    return (
        df.select("metric_id", "timestamp", "value")
          .withColumn("timestamp", F.to_utc_timestamp(F.col("timestamp"), "UTC"))
    )
```

## Commenting Rules (Spark-specific)

Add comments when:

* preventing a known Spark pitfall (shuffle, skew, non-determinism)
* selecting a join strategy or partitioning approach
* caching/persisting and the storage level choice is non-obvious

Do NOT comment:

* obvious DataFrame operations (select, withColumn, filter) restating what the code already communicates

### Bad vs Good comment example

```py
# BAD: narrates the obvious
df = df.repartition("metric_id")

# GOOD: explains the distributed-systems reason
# Repartition by metric_id to reduce shuffle during downstream groupBy on the same key.
df = df.repartition("metric_id")
```

## Performance & Correctness Guardrails

Avoid UDFs unless necessary; prefer built-in functions (pyspark.sql.functions) for performance and optimization.

If you must use UDFs:

* document why built-ins won’t work
* define return types explicitly
* keep UDF logic pure and deterministic
* Avoid collect() / toPandas() on large datasets; if used, justify with size bounds.
* Prefer broadcast() only when the right-side dataset is provably small; document the assumption.
* Cache/persist only when reused; unpersist when done in long-running jobs.

### Example: join with explicit strategy + column hygiene

```py
from pyspark.sql import functions as F

def enrich_with_dim(fact_df: DataFrame, dim_df: DataFrame) -> DataFrame:
    # Broadcast only if dim_df is known small (e.g., < 50MB); otherwise remove broadcast.
    dim = F.broadcast(dim_df.select("metric_id", "category").dropDuplicates(["metric_id"]))

    return (
        fact_df.alias("f")
        .join(dim.alias("d"), on="metric_id", how="left")
        .select(
            F.col("f.metric_id"),
            F.col("f.timestamp"),
            F.col("f.value"),
            F.col("d.category"),
        )
    )
```

## Determinism & Ordering

Never rely on row ordering unless you explicitly orderBy.
For window functions, always define a complete ordering (include tie-breakers if needed).

### Null Handling & Data Quality

* Be explicit about null semantics in filters and joins.
* Prefer isNull / isNotNull over equality comparisons to None.
* If dropping records, document the policy (what is dropped and why).

### Partitioning & Files

* When writing, prefer stable partitioning schemes; avoid high-cardinality partitions.
* Avoid small-file explosions; coalesce/repartition deliberately, with a documented reason.

### Testing Expectations (Spark)

* Prefer local SparkSession tests with small in-memory DataFrames.
* Assert schema and key invariants (column presence, types, nullability expectations).
* Avoid flaky tests: no dependence on current time, random seeds, or unordered results.

Example: deterministic DataFrame assertions

```py
from pyspark.sql import SparkSession
from pyspark.sql import functions as F

def assert_df_equals_unordered(actual: DataFrame, expected: DataFrame, key_cols: list[str]) -> None:
    # Compare as sets keyed by deterministic ordering.
    a = actual.orderBy(*key_cols).collect()
    e = expected.orderBy(*key_cols).collect()
    assert a == e
```

## Output Rules

* Prefer reusable transformation functions fn(df: DataFrame) -> DataFrame.
* Avoid embedding SparkSession creation inside transform modules unless it is explicitly the entrypoint.
* Do not introduce new Spark configs without documenting why and how they affect correctness/perf.

### Golden Rule

If a future engineer would reasonably ask “why is this here?”, add a short comment answering that question.