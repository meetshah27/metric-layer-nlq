-- q014 (time_window): How many racks reached production in each of the last 6 complete months? Return the month and the count.
select date_trunc('month', f.production_at) as month, count(*) as racks_to_production
from marts.fct_rack_delivery f
where f.production_at >= '2026-04-01' and f.production_at < '2026-10-01'
group by 1
;
