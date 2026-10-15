-- q019 (time_window): How many racks reached production in each of the last 4 complete weeks (weeks start Monday)?
select date_trunc('week', f.production_at) as week_start, count(*) as racks_to_production
from marts.fct_rack_delivery f
where f.production_at >= '2026-08-31' and f.production_at < '2026-09-28'
group by 1
;
