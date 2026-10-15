-- overdue_open_racks: In-flight racks past their SLA due date. Point in time (current state),
-- shown by order month; for the current total, drop the grouping.
-- Matches: mf query --metrics overdue_open_racks --group-by metric_time__month
select
    date_trunc('month', ordered_at) as month,
    sum(case when is_overdue_open then 1 else 0 end) as overdue_open_racks
from marts.fct_rack_delivery
where ordered_at is not null
group by 1
order by 1
;
