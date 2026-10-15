-- q052 alternative (volume): Which site is doing best?
select s.site_code, count(*) as racks_to_production
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where f.production_at >= '2026-09-01' and f.production_at < '2026-10-01'
group by 1
order by 2 desc
limit 1
;
