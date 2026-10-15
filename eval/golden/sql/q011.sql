-- q011 (simple_metric): What was the 90th percentile order-to-production time in days for racks that reached production in May 2026?
select percentile_cont(0.9) within group (order by f.end_to_end_hours) / 24.0 as p90_end_to_end_days
from marts.fct_rack_delivery f
where f.production_at >= '2026-05-01' and f.production_at < '2026-06-01'
;
