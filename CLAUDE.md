# CLAUDE.md: metric-layer-nlq

## What this repo is

Two things built on top of the `rack-delivery-pipeline` Redshift marts:

1. A governed metric layer: KPI definitions in the dbt Semantic Layer (MetricFlow), enforced dbt model contracts on the marts, and a generated metric dictionary.
2. A natural-language query (NLQ) service: Amazon API Gateway to AWS Lambda to Amazon Bedrock, which turns a business question into SQL grounded in the metric definitions, runs it read-only on Redshift Serverless via the Redshift Data API, and returns results. An evaluation harness measures execution accuracy against hand-written ground truth.

Read `docs/SPEC.md`, `docs/METRICS.md`, `docs/NLQ_SPEC.md`, `docs/EVAL_SPEC.md`, `docs/BUILD_PLAN.md` first.

## Dependency

The dbt project from `rack-delivery-pipeline` is added here as a dbt package (git dependency pinned to a tag) or the semantic models are added to that repo directly. Default: semantic models and contracts live in the P1 dbt project under `models/semantic/`; this repo holds the NLQ service, eval harness and generated docs, and reads the compiled `semantic_manifest.json` as an input artifact. Use this default.

## Hard rules

- The NLQ service never executes anything except a single `SELECT` (or `WITH ... SELECT`). Validate with `sqlglot` parsing (dialect `redshift`); reject DDL, DML, multiple statements, and references to schemas outside `marts`.
- The Redshift user/role for NLQ has `USAGE` and `SELECT` on `marts` only. Verify by attempting a write in a test and asserting it fails.
- Every generated query gets `LIMIT 1000` appended if absent.
- Bedrock model ID comes from env var `BEDROCK_MODEL_ID`. Never hardcode a model version. `BEDROCK_MODEL_ID_DEV` (a small, cheap model) is used for development runs; the final reported eval uses `BEDROCK_MODEL_ID`.
- Two execution backends behind one interface in `execute.py`: `duckdb` (local file copied from P1's `local/warehouse.duckdb`, used before the deployment window) and `redshift` (Redshift Data API). The guard parses in the backend's dialect. In local mode, ground-truth SQL is transpiled from Redshift to DuckDB with sqlglot at run time; the files in `eval/golden/sql/` stay in Redshift dialect.
- Reported accuracy numbers (README, SUMMARY headline, resume bullets) come only from runs on the `redshift` backend during the deployment window. Local runs are labeled `dev` in reports.
- No AWS resources other than Bedrock calls before the deployment window.
- Prompts live in `prompts/*.md` as versioned files. Every eval run records the prompt file hash.
- Golden questions and ground-truth SQL in `eval/golden/` are provided and fixed. Never change what a ground-truth query computes. If one errors only because of a mechanical mismatch with the real schema (a renamed column, a Redshift syntax restriction), fix the mechanics, keep the semantics identical, and log the before/after diff and reason in `eval/golden/CHANGELOG.md`. If a query's intended semantics cannot be expressed on the real schema, stop and report.
- Never read or print questions with `holdout: true` while iterating on prompts. Only `run_eval.py --include-holdout` touches them, and only in the final run of Phase 6.
- No metric may be defined in two places. The semantic YAML is the single source; the dictionary doc is generated from it.
- Tag resources `project=metric-layer-nlq`. No idle-cost resources.

## Stack

- Python 3.12, uv, ruff, mypy strict on `src/`.
- dbt-core 1.8+ with dbt-redshift, `dbt-metricflow` for local `mf` CLI.
- boto3 (bedrock-runtime Converse API, redshift-data), sqlglot, pydantic for request/response schemas.
- AWS SAM or Terraform for API Gateway + Lambda (choose Terraform to match P1).
- pytest; GitHub Actions.

## Layout

```
src/nlq/
  handler.py          Lambda entry
  context.py          builds grounding context from semantic_manifest.json
  generate.py         Bedrock call, returns SQL + chosen metric + confidence
  guard.py            sqlglot validation, schema allowlist, LIMIT
  execute.py          Redshift Data API run + poll + fetch
  models.py           pydantic schemas
prompts/
  system_v1.md
eval/
  golden/questions.yaml
  golden/sql/*.sql
  run_eval.py
  compare.py          result-set equivalence
  reports/
docs/
  generated/metric_dictionary.md
infra/
```

## Commands

```
make setup
make mf-validate        # mf validate-configs in the dbt project
make dictionary         # generate docs/generated/metric_dictionary.md
make deploy             # terraform apply for API + Lambda
make ask Q="..."        # call the deployed endpoint
make eval PROMPT=system_v1 MODE=grounded|schema_only
make test
```
