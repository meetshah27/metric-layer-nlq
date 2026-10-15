-- racks_on_time: Completed racks with production_at <= sla_due_at, by production month.
-- Matches: mf query --metrics racks_on_time --group-by metric_time__month
select
    date_trunc('month', production_at) as month,
    sum(case when not is_sla_breached then 1 else 0 end) as racks_on_time
from marts.fct_rack_delivery
where production_at is not null
group by 1
order by 1
;
