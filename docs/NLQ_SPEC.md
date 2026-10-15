# NLQ SERVICE SPEC

## Request flow

1. API Gateway (HTTP API) `POST /ask`, IAM auth or an API key; throttle 5 req/s.
2. Lambda `handler.py` validates input with pydantic (question 5 to 500 chars).
3. `context.py` builds the prompt context:
   - `schema_only` mode: table and column names, types, descriptions from dbt `manifest.json` for marts only.
   - `grounded` mode: the above plus every metric's name, description, formula, time anchor, exclusions, and its canonical example SQL.
4. `generate.py` calls Bedrock Converse API with the system prompt from `prompts/` and asks for a JSON object:
   ```json
   {"metric_used": "on_time_delivery_rate" | null,
    "can_answer": true,
    "sql": "...",
    "assumptions": ["interpreted 'last quarter' as 2026-07-01 to 2026-09-30"]}
   ```
   Use tool use / structured output so the response is guaranteed JSON. Temperature 0.
5. If `can_answer` is false, return `status: refused` with the model's reason.
6. `guard.py`:
   - parse with sqlglot redshift dialect; exactly one statement; root is Select (or With wrapping Select)
   - every table reference resolves to `marts.*`
   - no functions on a denylist (e.g. anything system-level)
   - append `LIMIT 1000` if missing
   - run `EXPLAIN` first; reject if the plan's top cost exceeds a configured threshold
   On rejection return `status: rejected_sql` with the reason; do not execute.
7. `execute.py` runs via Redshift Data API with the NLQ secret / IAM role, polls with backoff, timeout 30s, returns rows.
8. Response includes `sql` and `assumptions` so a human can audit.

## Prompt requirements (`prompts/system_v1.md`)

- Role: analyst writing Redshift SQL against the listed marts only.
- Must use metric definitions verbatim when the question matches a metric (grounded mode).
- Must refuse when the question needs data not in the marts (e.g. cost per rack, vendor ratings).
- Must state date interpretation assumptions in `assumptions`. Current date is passed in at request time.
- Default rules for ambiguous questions (state the rule used in `assumptions`):
  - No time window given: use the last complete calendar month.
  - "Last quarter", "last month": the last complete calendar quarter or month before the current date.
  - "Trailing N days": the N days ending the day before the current date.
  - A month named without a year: the most recent complete occurrence of that month.
  - "How are we doing" on delivery: on_time_delivery_rate. "How fast": p50_end_to_end_days. "Slowest vendor": highest p50_end_to_end_days. "Behind": overdue_open_racks. "Busy": racks_to_production. "Doing best" for a site: highest on_time_delivery_rate among sites with at least 20 completed racks.
  - Weeks start on Monday.
- Rates over multiple groups are always pooled (sum of numerators over sum of denominators), never an average of group rates. Averages of durations are per rack, never an average of group averages.
- Must not invent columns.

## Logging

Each request logs (CloudWatch, structured JSON): request_id, question, mode, metric_used, status, sql, latency per step, input/output token counts, est_cost_usd. No result rows in logs.

## Infra

Terraform: Lambda (Python 3.12, 512 MB, 60s timeout), HTTP API, IAM role with `bedrock:InvokeModel` on the configured model ARN only, `redshift-data:*Statement*` and `redshift-serverless:GetCredentials` scoped to the workgroup, Secrets or IAM DB auth for the read-only DB user.
