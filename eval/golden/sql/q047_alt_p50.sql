-- q047 alternative (p50): How are we doing on delivery?
select percentile_cont(0.5) within group (order by f.end_to_end_hours) / 24.0 as p50_end_to_end_days
from marts.fct_rack_delivery f
where f.production_at >= '2026-09-01' and f.production_at < '2026-10-01'
;
