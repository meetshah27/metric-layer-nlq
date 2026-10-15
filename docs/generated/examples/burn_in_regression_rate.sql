-- burn_in_regression_rate: Share of completed racks with at least one status regression, by production month.
-- Pooled: regressed racks / completed racks.
-- Matches: mf query --metrics burn_in_regression_rate --group-by metric_time__month
select
    date_trunc('month', production_at) as month,
    sum(case when regression_count > 0 then 1 else 0 end)::float8
        / nullif(count(*), 0) as burn_in_regression_rate
from marts.fct_rack_delivery
where production_at is not null
group by 1
order by 1
;
