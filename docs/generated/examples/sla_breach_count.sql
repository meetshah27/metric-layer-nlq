-- sla_breach_count: Completed racks that missed SLA, by production month.
-- Matches: mf query --metrics sla_breach_count --group-by metric_time__month
select
    date_trunc('month', production_at) as month,
    sum(case when is_sla_breached then 1 else 0 end) as sla_breach_count
from marts.fct_rack_delivery
where production_at is not null
group by 1
order by 1
;
