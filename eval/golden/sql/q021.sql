-- q021 (time_window): In the last 30 days, which single day had the most racks reach production, and how many?
select trunc(f.production_at) as day, count(*) as racks_to_production
from marts.fct_rack_delivery f
where f.production_at >= '2026-09-01' and f.production_at < '2026-10-01'
group by 1
order by 2 desc
limit 1
;
