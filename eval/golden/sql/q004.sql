-- q004 (simple_metric): What was the median order-to-production time in days for racks that reached production in June 2026?
select percentile_cont(0.5) within group (order by f.end_to_end_hours) / 24.0 as p50_end_to_end_days
from marts.fct_rack_delivery f
where f.production_at >= '2026-06-01' and f.production_at < '2026-07-01'
;
