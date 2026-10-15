-- q018 (time_window): What was the 90th percentile order-to-production time in days for each month of Q3 2026?
select date_trunc('month', f.production_at) as month,
       percentile_cont(0.9) within group (order by f.end_to_end_hours) / 24.0 as p90_end_to_end_days
from marts.fct_rack_delivery f
where f.production_at >= '2026-07-01' and f.production_at < '2026-10-01'
group by 1
;
