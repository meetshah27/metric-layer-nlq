-- q017 (time_window): Compare the on-time delivery rate in Q3 2026 with Q3 2025. Return the quarter and the rate.
select date_trunc('quarter', f.production_at) as quarter, count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
where (f.production_at >= '2025-07-01' and f.production_at < '2025-10-01')
   or (f.production_at >= '2026-07-01' and f.production_at < '2026-10-01')
group by 1
;
