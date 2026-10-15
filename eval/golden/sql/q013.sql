-- q013 (time_window): What was the on-time delivery rate last quarter?
select count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
where f.production_at >= '2026-07-01' and f.production_at < '2026-10-01'
;
