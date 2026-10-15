-- q012 (simple_metric): What share of racks that reached production in 2025 had at least one status regression?
select count(case when f.regression_count > 0 then 1 end)::float8 / nullif(count(*), 0) as burn_in_regression_rate
from marts.fct_rack_delivery f
where f.production_at >= '2025-01-01' and f.production_at < '2026-01-01'
;
