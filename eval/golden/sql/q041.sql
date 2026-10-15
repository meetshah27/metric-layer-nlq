-- q041 (ratio_trap): What was the overall on-time delivery rate across all vendors for racks reaching production between January and September 2026?
select count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
where f.production_at >= '2026-01-01' and f.production_at < '2026-10-01'
;
