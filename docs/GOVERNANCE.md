# Metric governance

How the rack delivery KPIs are owned, changed and retired. Applies to every metric in the [metric dictionary](generated/metric_dictionary.md) and to every mart model those metrics read.

## One definition per metric

Each metric is defined once, in the dbt Semantic Layer (`dbt/models/semantic/metrics.yml` in rack-delivery-pipeline). The dashboard, the natural-language query service and anyone writing SQL use that definition. The metric dictionary is generated from it and never edited by hand. A number that disagrees with the semantic layer is a bug in whatever produced it, not a second opinion.

## Ownership

Every metric has a named owner, recorded in its `meta.owner`. The owner:

- approves any change to the metric's definition, formula, time anchor or exclusions
- answers questions about what the metric means
- is paged when the metric's source fails its refresh SLA

A metric without an owner is not published.

## Changing a metric

1. **Open a pull request** against the semantic YAML that states what changes, why, and which reports or golden questions it affects.
2. **Run the checks.** CI runs `mf validate-configs` (including a query of every metric against the warehouse) and the full dbt build with contracts. Both must pass.
3. **Update dependents in the same pull request:** the canonical example query, any affected ground-truth SQL in the NLQ golden set (logged in `eval/golden/CHANGELOG.md`), and the regenerated dictionary (`make dictionary`; CI fails if it is stale).
4. **Get owner approval.** A change to the meaning of a metric (formula, anchor, exclusions) needs the owner. A change to its wording or description needs any reviewer.
5. **Announce it** in the release notes with the effective date, so a step change in a chart has an explanation.

Changing the meaning of an existing metric in place is the exception, not the rule. If people may compare old and new values, create a new metric (for example `on_time_delivery_rate_v2`) and deprecate the old one.

## Contracts on the marts

Every mart model has an enforced dbt contract: each column's name and type is declared, and the build fails before a table is replaced if they drift ([demo](contract_demo.md)).

- **Non-breaking changes** (a new column, a new model) need a normal review.
- **Breaking changes** (removing or renaming a column, changing its type or meaning) never replace a model in place. They ship as a new model `version`:
  1. Add `versions:` to the model with the new version, and keep the old one as `latest_version` until consumers have moved.
  2. Set a `deprecation_date` on the old version, at least 30 days out.
  3. Point the semantic layer, dashboard datasets and NLQ grounding at the new version, and confirm each one.
  4. Make the new version `latest` and remove the old one after its deprecation date.

## Retiring a metric

1. Mark it deprecated in its description, with the replacement and a removal date at least one month out.
2. Remove it from dashboards and from the NLQ grounding, so the service stops choosing it for new questions.
3. Delete it from the semantic YAML after the removal date and regenerate the dictionary.

## Refresh SLAs

Each metric records its refresh SLA (`meta.refresh_sla`). The pipeline's source freshness check fails the run if raw data is older than 26 hours. A missed SLA is reported on the dashboard's pipeline health sheet before anyone reads a stale number.
