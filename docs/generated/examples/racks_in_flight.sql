-- racks_in_flight: Racks ordered and not yet in production or decommissioned. Point in time (current state),
-- shown by order month; for the current total, drop the grouping.
-- Matches: mf query --metrics racks_in_flight --group-by metric_time__month
select
    date_trunc('month', ordered_at) as month,
    sum(case when production_at is null and decommissioned_at is null then 1 else 0 end)
        as racks_in_flight
from marts.fct_rack_delivery
where ordered_at is not null
group by 1
order by 1
;
