# BUILD PLAN: Metric Layer and NLQ

Prerequisite: P1 Phase 5 complete on the local track (DuckDB marts exist).

$0 execution order (see docs/DEPLOY_WINDOW.md):
- Local: 0, 1, 2, 3 against the DuckDB backend; Phase 5 harness built and smoke-tested locally with the dev model; Phase 6 prompt iteration may run locally with the dev model on non-holdout questions.
- Deployment window: 1 again on Redshift (`mf validate-configs` and example-query tests), 4, then the final runs of 5 and 6 on the Redshift backend with the final model, then 7 and 8.

## Phase 0: Scaffold
- Layout, pyproject, Makefile, CI, `.env.example` (AWS_PROFILE, AWS_REGION, REDSHIFT_WORKGROUP, REDSHIFT_DATABASE, BEDROCK_MODEL_ID, NLQ_DB_USER).
- Acceptance: `make setup`, `make test` pass.

## Phase 1: Contracts and semantic layer (in the P1 dbt project)
- Add `contract: enforced: true` with explicit data types to every mart model.
- Add semantic models for `fct_rack_delivery` with entities, dimensions (joined dims), measures; define all 12 metrics from METRICS.md.
- `mf validate-configs` passes.
- Canonical example SQL per metric and a test comparing it to `mf query` output.
- Demonstrate contract enforcement: on a branch, change a mart column type; show `dbt build` fails with a contract error. Record the output in `docs/contract_demo.md`, then revert.
- Acceptance: all of the above with command output shown.

## Phase 2: Dictionary and governance
- `make dictionary` reads `semantic_manifest.json`, writes `docs/generated/metric_dictionary.md` with every column from METRICS.md.
- `docs/GOVERNANCE.md`: change process, owner approval, contract versioning (`version` on models), deprecation steps. One page, written as a team policy.
- Acceptance: dictionary regenerates deterministically; diff is empty on rerun.

## Phase 3: NLQ core (local)
- `context.py`, `generate.py`, `guard.py`, `execute.py`, `models.py`, prompt v1.
- Unit tests for guard: rejects INSERT, DROP, two statements, `pg_catalog`/`stl_` references, non-marts schema; adds LIMIT; accepts CTE selects.
- Integration test: read-only DB user cannot `CREATE TABLE marts.x` (assert failure).
- Local CLI `python -m nlq.cli "question"` runs end to end.
- Acceptance: tests pass; 3 sample questions answered locally with SQL printed.

## Phase 4: Deploy
- Terraform for Lambda + HTTP API + IAM scoped as in NLQ_SPEC.
- `make ask` works against the deployed endpoint.
- Structured logs visible in CloudWatch.
- Acceptance: one answered, one refused, one rejected_sql example captured in `docs/examples.md`.

## Phase 5: Eval harness (golden set is provided)
- `run_eval.py`, `compare.py` with unit tests on tricky equivalence cases (column order, float tolerance, ties).
- Validate the golden set first: run every ground-truth and alternative query; log any mechanical fixes per CLAUDE.md.
- Run both modes x3 on the 45 non-holdout questions. Generate reports and SUMMARY.
- Label every failure with one taxonomy label from EVAL_SPEC, using this rubric in order (first match wins): SQL error; should have refused; refused wrongly; hallucinated column; wrong metric (chose a different measure); wrong date window; wrong filter; wrong aggregation. Store labels in `eval/reports/failure_labels.csv` with a one-line justification each.
- Acceptance: SUMMARY shows both modes; every failure is labeled.

## Phase 6: Iterate at most twice, then the holdout run
- From the failure labels, write `prompts/system_v2.md`. Each change must name the failure label it targets. Changes must be general rules (for example, "pool rates across groups"), never question-specific hints, never literal values copied from a golden question.
- Rerun grounded mode on non-holdout questions. If accuracy is still improving and failures point to a clear general rule, one more iteration (v3) is allowed. Then stop.
- Final run: best prompt version, both modes, `--include-holdout`, 3 repeats. Report non-holdout and holdout accuracy separately. The holdout number is the honest one and leads the README.
- Record all versions in SUMMARY.

## Phase 7: README
- Headline accuracy sentence, architecture diagram, metric dictionary link, guard design, eval method, failure taxonomy chart, cost per question, limitations.
- `docs/RESUME_BULLETS.md`: 2 bullets with numbers.
- `docs/INTERVIEW_PREP.md`: how the guard blocks unsafe SQL, why execution accuracy instead of SQL string match, why grounding helps and where it still fails (cite the failure taxonomy), why a holdout set, the overfitting risk in prompt iteration, cost per question, and 10 likely interviewer questions with answers.

## Phase 8: Evidence capture and teardown
- Commit all eval reports, SUMMARY, failure labels, and `docs/examples.md` with real responses from the deployed endpoint.
- asciinema recording of three `make ask` calls against the live API (answered, refused, rejected_sql), converted to GIF with `agg`, embedded in README.
- CloudWatch latency and error charts exported with `GetMetricWidgetImage` to `docs/img/`.
- Publish the metric dictionary and eval SUMMARY as a one-page GitHub Pages site.
- README deployment-window statement with real dates and request counts.
- `make teardown` (API Gateway, Lambda, IAM, logs). Verify the tag-based resource search returns nothing for `project=metric-layer-nlq`.
