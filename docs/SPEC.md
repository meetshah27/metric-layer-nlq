# SPEC: Metric Layer and NLQ

## 1. Problem

Different people computing "on-time delivery rate" from the same tables get different numbers because they choose different denominators, date anchors and exclusions. And leaders want to ask questions without writing SQL. An NLQ tool that writes its own definitions makes the first problem worse. The fix is to make the governed metric definitions the grounding for the model, then measure whether that actually improves accuracy.

## 2. Goals

1. Every KPI in `METRICS.md` has one machine-readable definition, an owner, a refresh SLA, and tests.
2. Mart schemas are contract-enforced: a breaking column change fails CI before it reaches the dashboard.
3. NLQ service answers questions about those KPIs, refuses questions that map to no defined metric, and never runs unsafe SQL.
4. Measured execution accuracy on a 60-question golden set, reported for two modes:
   - `schema_only`: prompt contains table and column descriptions only.
   - `grounded`: prompt also contains metric definitions, formulas, and canonical example queries from the semantic manifest.
   The difference between modes is the headline result.

## 3. Non-goals

A chat UI beyond a minimal HTML page, multi-turn conversation, write access, fine-tuning.

## 4. Components

- Semantic models and metrics: `models/semantic/*.yml` in the P1 dbt project.
- Model contracts: `contract: {enforced: true}` on every mart model with explicit `data_type` per column, plus `constraints` (not_null, primary_key as informational).
- Dictionary generator: reads `semantic_manifest.json`, writes markdown table per metric.
- NLQ API: `POST /ask {question}` returns `{status, metric_used, sql, rows, row_count, latency_ms, model_id, prompt_hash}`; `status` in `answered | refused | rejected_sql | error`.
- Minimal static HTML page (S3 + CloudFront not needed; serve from a Lambda function URL or keep local) with a text box and result table. Optional.
- Eval harness: runs all golden questions through the same code path as the API (direct function call, not HTTP), compares result sets, writes a report.

## 5. Optional: Amazon Q in QuickSight comparison

If you choose to pay for a QuickSight Pro (Amazon Q) seat for a month, ask a 20-question subset in Q and record whether each answer matches ground truth. Document cost and results. Not required.

## 6. Deliverables

- Metric dictionary (generated) and one-page metric governance note: who owns changes, how a definition change is reviewed, how contracts block breaking changes.
- NLQ endpoint deployed in dev.
- Eval report: accuracy by mode and by question category, failure taxonomy, latency p50/p95, Bedrock cost per question.
- README with the before/after accuracy number first.
