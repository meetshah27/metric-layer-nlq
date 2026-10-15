# EVAL SPEC

## Golden set (provided)

`eval/golden/questions.yaml` and `eval/golden/sql/` are already written: 60 questions, 52 ground-truth queries (the 8 should_refuse questions have none), and 9 alternative queries for ambiguous questions. Entry format:

```yaml
- id: q003
  question: "What was the on-time delivery rate for vendor V03 in August 2026?"
  category: simple_metric        # see categories
  expected_metric: on_time_delivery_rate
  ground_truth_sql: sql/q003.sql
  should_refuse: false
  alternative_sql: []            # extra accepted answers, ambiguous category only
  allow_ties: false
  requires_assumption: false     # true: response must include a non-empty assumptions list
  holdout: false                 # 15 questions; excluded from prompt iteration
  notes: ""
```

Category quotas:

| Category | Count | Example |
|---|---|---|
| simple_metric | 12 | single metric, single filter |
| time_window | 10 | "last quarter", "month over month", "trailing 90 days" |
| group_by_rank | 10 | "which 3 sites had the worst p90 install time in 2026" |
| multi_join | 8 | needs vendor SCD2 as-of logic or multiple dims |
| ratio_trap | 6 | questions where a naive average of ratios is wrong |
| ambiguous | 6 | "how are we doing on delivery" (correct = state assumption, pick on_time_delivery_rate) |
| should_refuse | 8 | "what's the cost per rack", "which vendor is cheapest" |

Questions use fixed dates, not "today", except time_window and ambiguous, where the eval passes `eval_current_date` (2026-10-01) as the request's current date. Phase 5 begins by running every ground-truth and alternative query against the live marts and asserting each returns at least one row (except where an empty result is a legitimate answer, flagged in notes).

## Comparison (`compare.py`)

A generated answer is correct if:
- `should_refuse: true` and status is `refused` (for the write request q058, `rejected_sql` also counts); or
- the result matches the ground truth or any alternative, where "matches" means:
  - same number of rows
  - every ground-truth column can be mapped to a distinct generated column with equal values in every row after sorting rows; extra generated columns are allowed; column names and order are ignored
  - numeric values equal within relative tolerance 1e-6 or absolute 1e-9; timestamps and dates compared after truncating both to date when one side is a date; nulls equal
- and, if `requires_assumption: true`, the response's `assumptions` list is non-empty.
- If `allow_ties: true`, the harness computes the tie-inclusive set from the ground truth (rerun without LIMIT) and accepts any generated rows that are a valid selection from it.

Do not use string comparison of SQL. Do not use an LLM to judge correctness.

## Runs

`make eval PROMPT=system_v1 MODE=schema_only` and `MODE=grounded`. Run each 3 times (temperature 0 still varies slightly); report mean and min.

## Report (`eval/reports/<timestamp>_<mode>.md` + `.json`)

- Overall execution accuracy.
- Accuracy by category.
- Refusal precision and recall.
- Guard rejections count.
- Failure taxonomy (labeled with the Phase 5 rubric): wrong metric, wrong filter, wrong date window, wrong aggregation (ratio of averages), hallucinated column, SQL error, should have refused, refused wrongly.
- Latency p50/p95 per step; Bedrock tokens and cost per question.
- Prompt hash, model ID, git SHA.

`eval/reports/SUMMARY.md` is regenerated with a comparison table of all runs. The headline sentence in the README comes from it: "Grounding the model in governed metric definitions raised execution accuracy from X% to Y% on 60 questions; ratio_trap accuracy went from A% to B%."

## CI

A smoke subset (10 questions, grounded) runs in CI on changes to `prompts/` or `src/nlq/`, gated behind a manual workflow dispatch to control cost. Fail if accuracy drops more than 10 points versus the last committed SUMMARY.
