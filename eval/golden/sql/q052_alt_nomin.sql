-- q052 alternative (nomin): Which site is doing best?
select s.site_code, count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where f.production_at >= '2026-09-01' and f.production_at < '2026-10-01'
group by 1
order by 2 desc
limit 1
;
