# METRICS (source of truth for what to define in MetricFlow)

Status: approved. Claude Code translates this table into semantic YAML exactly. The golden question set in `eval/golden/` is written against these definitions, so do not change a definition without updating the affected ground-truth queries and logging it in `eval/golden/CHANGELOG.md`.

All metrics use time dimension and grain as stated. "Completed" means `production_at is not null`.

| # | Metric name | Definition | Formula | Time anchor | Grain | Source model | Owner | Refresh SLA | Exclusions |
|---|---|---|---|---|---|---|---|---|---|
| 1 | racks_ordered | Racks with an order placed | count(rack_id) | ordered_at | day | fct_rack_delivery | Meet | Daily 08:00 UTC | none |
| 2 | racks_to_production | Racks reaching production | count(rack_id) where production_at not null | production_at | day | fct_rack_delivery | Meet | Daily 08:00 UTC | none |
| 3 | on_time_delivery_rate | Share of completed racks reaching production by SLA due date | racks_on_time / racks_to_production | production_at | month | fct_rack_delivery | Meet | Daily | decommissioned before production (already excluded because production_at is null) |
| 4 | racks_on_time | Completed racks with production_at <= sla_due_at | count where not is_sla_breached and production_at not null | production_at | day | fct_rack_delivery | Meet | Daily | same as 3 |
| 5 | p50_end_to_end_days | Median order-to-production days | percentile_cont(0.5) of end_to_end_hours / 24 | production_at | month | fct_rack_delivery | Meet | Daily | none |
| 6 | p90_end_to_end_days | 90th percentile order-to-production days | percentile_cont(0.9) of end_to_end_hours / 24 | production_at | month | fct_rack_delivery | Meet | Daily | none |
| 7 | avg_vendor_lead_days | Mean ORDERED to SHIPPED days | avg(vendor_lead_hours)/24 | shipped_at | month | fct_rack_delivery | Meet | Daily | none |
| 8 | avg_install_days | Mean RECEIVED to CABLED days | avg(install_hours)/24 | cabled_at | month | fct_rack_delivery | Meet | Daily | none |
| 9 | racks_in_flight | Racks ordered and not yet in production (point in time) | count where production_at is null and decommissioned_at is null | snapshot date | day | fct_rack_delivery | Meet | Daily | none |
| 10 | overdue_open_racks | In-flight racks past SLA due date | count where is_overdue_open | snapshot date | day | fct_rack_delivery | Meet | Daily | none |
| 11 | sla_breach_count | Completed racks that missed SLA | count where is_sla_breached and production_at not null | production_at | day | fct_rack_delivery | Meet | Daily | none |
| 12 | burn_in_regression_rate | Share of completed racks with at least one status regression (the simulator only produces BURN_IN to CABLED regressions, so in practice this is burn-in failures) | count(regression_count > 0) / racks_to_production | production_at | month | fct_rack_delivery | Meet | Daily | none |

Dimensions available to every metric: vendor (vendor_name, contract_tier), site (site_name, site_region), rack_type (description, is_gpu), metric_time.

Notes for implementation
- MetricFlow supports `percentile` aggregation on Redshift; if `percentile_cont` is not supported for a given configuration, raise it rather than switching to an approximation silently.
- Metrics 9 and 10 are point-in-time; implement against a daily snapshot or document the limitation that they reflect the current state only.
- Ratio metrics (3, 12) defined with `type: ratio` referencing numerator and denominator metrics, not as a single expression, so they aggregate correctly across dimensions.

## Canonical example queries

For each metric, Claude Code writes one reference SQL query (`docs/generated/examples/<metric>.sql`) against the marts that reproduces `mf query --metrics <metric> --group-by metric_time__month` output. A test asserts both return identical results. These examples become part of the grounded prompt.

## Implementation notes for the fact table flags

- `is_sla_breached` = `production_at > sla_due_at`, and false when `production_at` is null. The on-time numerator for completed racks is therefore `not is_sla_breached`.
- `is_overdue_open` = `production_at is null and decommissioned_at is null and current_timestamp > sla_due_at`.
- `sla_due_at` = `ordered_at + sla_days * interval '1 day'`, using the SLA from the vendor version in effect at `ordered_at`.
- `days_in_current_status` is computed at build time from `current_timestamp`.
