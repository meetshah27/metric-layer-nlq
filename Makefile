# metric-layer-nlq: semantic layer checks, metric dictionary, NLQ service and evaluation.
# Targets not built yet exit 1, so nothing silently "succeeds".

SHELL := /bin/sh
# The rack-delivery-pipeline dbt project, which holds the semantic models and contracts.
P1_DBT_DIR ?= ../p1-rack-delivery-pipeline/dbt

define not_implemented
	@echo "make $@: not implemented yet ($(1))" >&2; exit 1
endef

.PHONY: setup lint typecheck test mf-validate sync-artifacts dictionary deploy ask eval teardown

setup:
	uv sync

lint:
	uv run ruff check .
	uv run ruff format --check .

typecheck:
	uv run mypy src

# tests/test_metric_examples.py needs the rack-delivery-pipeline warehouse; it skips without one.
test:
	uv run pytest -q

# PYTHONUTF8 keeps mf's progress spinner from failing on Windows consoles.
mf-validate:
	cd $(P1_DBT_DIR) && PYTHONUTF8=1 uv run mf validate-configs

# Pin the compiled semantic layer this repo is built against (input artifact, committed).
sync-artifacts:
	cd $(P1_DBT_DIR) && uv run dbt parse --target local --quiet
	mkdir -p artifacts && cp $(P1_DBT_DIR)/target/semantic_manifest.json artifacts/

dictionary:
	uv run python -m nlq.dictionary

ask:
	$(call not_implemented,NLQ service)

deploy:
	$(call not_implemented,deployment)

eval:
	$(call not_implemented,evaluation harness)

teardown:
	$(call not_implemented,teardown)
