-- q015 (time_window): For each of the last 3 complete months, how many racks reached production and what was the change from the previous month?
with monthly as (
    select date_trunc('month', f.production_at) as month, count(*) as racks_to_production
    from marts.fct_rack_delivery f
    where f.production_at >= '2026-06-01' and f.production_at < '2026-10-01'
    group by 1
),
with_change as (
    select month, racks_to_production,
           racks_to_production - lag(racks_to_production) over (order by month) as change_from_prior_month
    from monthly
)
select month, racks_to_production, change_from_prior_month
from with_change
where month >= '2026-07-01'
;
