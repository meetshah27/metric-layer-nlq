-- on_time_delivery_rate: Share of completed racks in production by their SLA due date, by production month.
-- Pooled: on-time racks / completed racks. Never average per-group rates.
-- Matches: mf query --metrics on_time_delivery_rate --group-by metric_time__month
select
    date_trunc('month', production_at) as month,
    sum(case when not is_sla_breached then 1 else 0 end)::float8
        / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery
where production_at is not null
group by 1
order by 1
;
