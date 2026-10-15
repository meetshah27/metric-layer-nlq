"""Each canonical example query returns exactly what MetricFlow returns for its metric.

Runs `mf query --metrics <metric> --group-by metric_time__month` in the rack-delivery-pipeline
dbt project and the example SQL (Redshift dialect, transpiled to DuckDB with sqlglot) against
that project's local DuckDB warehouse. Skipped when the project or warehouse is not present:
point P1_DBT_DIR at rack-delivery-pipeline/dbt after `make dbt-local` there.
"""

from __future__ import annotations

import csv
import math
import os
import subprocess
from datetime import datetime
from pathlib import Path

import duckdb
import pytest
import sqlglot

ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = ROOT / "docs" / "generated" / "examples"
P1_DBT_DIR = Path(os.environ.get("P1_DBT_DIR", ROOT.parent / "p1-rack-delivery-pipeline" / "dbt"))
WAREHOUSE = P1_DBT_DIR.parent / "local" / "warehouse.duckdb"
METRICS = sorted(p.stem for p in EXAMPLES.glob("*.sql"))

pytestmark = pytest.mark.skipif(
    not WAREHOUSE.exists(), reason=f"no rack-delivery-pipeline warehouse at {WAREHOUSE}"
)

Row = tuple[datetime, float]


def _mf_query(metric: str, out: Path) -> list[Row]:
    subprocess.run(
        [
            "uv",
            "run",
            "mf",
            "query",
            "--metrics",
            metric,
            "--group-by",
            "metric_time__month",
            "--csv",
            str(out),
        ],
        cwd=P1_DBT_DIR,
        env={**os.environ, "PYTHONUTF8": "1"},
        check=True,
        capture_output=True,
    )
    rows: list[Row] = []
    with out.open() as f:
        for record in csv.DictReader(f):
            month, value = record["metric_time__month"], record[metric]
            # MetricFlow also emits a group for racks whose time anchor is null (e.g. not yet
            # in production); the canonical SQL filters on the anchor, so that group is not
            # part of the comparison.
            if month:
                rows.append((datetime.fromisoformat(month), float(value) if value else math.nan))
    return sorted(rows)


def _example_query(metric: str) -> list[Row]:
    sql = (EXAMPLES / f"{metric}.sql").read_text()
    duck_sql = sqlglot.transpile(sql, read="redshift", write="duckdb")[0]
    with duckdb.connect(str(WAREHOUSE), read_only=True) as con:
        result = con.sql(duck_sql).fetchall()
    return sorted((month, float(value)) for month, value in result)


@pytest.fixture(scope="module")
def mf_results(tmp_path_factory: pytest.TempPathFactory) -> dict[str, list[Row]]:
    # all mf queries first: dbt-duckdb holds a write lock while mf runs
    out = tmp_path_factory.mktemp("mf")
    return {metric: _mf_query(metric, out / f"{metric}.csv") for metric in METRICS}


def test_every_governed_metric_has_an_example() -> None:
    assert len(METRICS) == 12


@pytest.mark.parametrize("metric", METRICS)
def test_example_matches_mf_query(metric: str, mf_results: dict[str, list[Row]]) -> None:
    expected, actual = mf_results[metric], _example_query(metric)
    assert [month for month, _ in actual] == [month for month, _ in expected]
    for (month, got), (_, want) in zip(actual, expected, strict=True):
        assert got == pytest.approx(want, rel=1e-9, abs=1e-9), f"{metric} {month:%Y-%m}"
