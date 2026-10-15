"""The generated dictionary is deterministic, committed fresh, and matches docs/METRICS.md."""

from __future__ import annotations

import json
from typing import Any

import pytest

from nlq import dictionary

ROOT = dictionary.ROOT


@pytest.fixture(scope="module")
def manifest() -> dict[str, Any]:
    result: dict[str, Any] = json.loads(dictionary.MANIFEST.read_text(encoding="utf-8"))
    return result


def _approved_metrics() -> dict[str, dict[str, str]]:
    """Rows of the table in docs/METRICS.md, keyed by metric name."""
    lines = (ROOT / "docs" / "METRICS.md").read_text(encoding="utf-8").splitlines()
    table = [line for line in lines if line.startswith("|")]
    header = [cell.strip() for cell in table[0].strip("|").split("|")]
    rows = {}
    for line in table[2:]:
        cells = dict(zip(header, (c.strip() for c in line.strip("|").split("|")), strict=True))
        rows[cells["Metric name"]] = cells
    return rows


def test_render_is_deterministic(manifest: dict[str, Any]) -> None:
    assert dictionary.render(manifest) == dictionary.render(manifest)


def test_committed_dictionary_is_fresh(manifest: dict[str, Any]) -> None:
    committed = dictionary.OUTPUT.read_text(encoding="utf-8")
    assert committed == dictionary.render(manifest), "run `make dictionary` and commit"


def test_every_approved_metric_is_defined_with_its_governance(manifest: dict[str, Any]) -> None:
    approved = _approved_metrics()
    assert len(approved) == 12
    defined = {m["name"]: m["config"]["meta"] for m in manifest["metrics"]}
    for name, row in approved.items():
        assert name in defined, f"{name} missing from the semantic layer"
        meta = defined[name]
        assert meta["owner"] == row["Owner"], name
        assert meta["grain"] == row["Grain"], name
        assert meta["source_model"] == row["Source model"], name
        assert meta["refresh_sla"] == row["Refresh SLA"], name


def test_dictionary_lists_every_approved_metric(manifest: dict[str, Any]) -> None:
    rendered = dictionary.render(manifest)
    for name in _approved_metrics():
        assert f"| `{name}` |" in rendered
        assert f"(examples/{name}.sql)" in rendered
