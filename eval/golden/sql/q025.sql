-- q025 (group_by_rank): Which region had the most racks reach production in Q3 2026?
select s.site_region, count(*) as racks_to_production
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where f.production_at >= '2026-07-01' and f.production_at < '2026-10-01'
group by 1
order by 2 desc
limit 1
;
