-- p50_end_to_end_days: Median order-to-production days, by production month.
-- Matches: mf query --metrics p50_end_to_end_days --group-by metric_time__month
select
    date_trunc('month', production_at) as month,
    percentile_cont(0.5) within group (order by end_to_end_hours / 24.0) as p50_end_to_end_days
from marts.fct_rack_delivery
where production_at is not null
group by 1
order by 1
;
