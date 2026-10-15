# metric-layer-nlq. Targets mirror CLAUDE.md "Commands".
# Stubs exit 1 with the phase that implements them, so nothing silently "succeeds".

SHELL := /bin/sh

define not_implemented
	@echo "make $@: not implemented (BUILD_PLAN $(1))" >&2; exit 1
endef

.PHONY: setup lint typecheck test mf-validate dictionary deploy ask eval teardown

setup:
	uv sync

lint:
	uv run ruff check .
	uv run ruff format --check .

typecheck:
	uv run mypy src

# pytest exit code 5 means "no tests collected", which is fine until tests land.
test:
	uv run pytest -q || [ $$? -eq 5 ]

mf-validate:
	$(call not_implemented,Phase 1)

dictionary:
	$(call not_implemented,Phase 2)

ask:
	$(call not_implemented,Phase 3 locally / Phase 4 deployed)

deploy:
	$(call not_implemented,Phase 4)

eval:
	$(call not_implemented,Phase 5)

teardown:
	$(call not_implemented,Phase 8)
