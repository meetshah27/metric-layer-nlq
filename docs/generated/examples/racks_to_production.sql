-- racks_to_production: Racks reaching production, by production month.
-- Matches: mf query --metrics racks_to_production --group-by metric_time__month
select
    date_trunc('month', production_at) as month,
    count(*) as racks_to_production
from marts.fct_rack_delivery
where production_at is not null
group by 1
order by 1
;
