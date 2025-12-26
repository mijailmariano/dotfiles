---
applyTo: "**/*spark*.py"
---

# Spark / PySpark Instructions

## Core Principles
- Prefer DataFrame APIs over RDDs unless there is a clear, documented need.
- Keep transformations deterministic and schema-explicit; avoid silent type coercions.
- Treat Spark jobs as distributed systems: minimize shuffles, avoid wide dependencies, and control cardinality blowups.
- Separate concerns:
  - I/O + session setup
  - transformations (pure-ish)
  - orchestration (job wiring, arguments, outputs)

## Schema & Contracts (Mandatory)
- Always define/validate schemas at boundaries (reads, external inputs, UDF inputs/outputs).
- Prefer `select` with explicit columns over `select("*")` in production pipelines.
- When joining:
  - validate join keys exist and are non-null when required
  - explicitly resolve duplicate column names (avoid accidental overwrites)

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
