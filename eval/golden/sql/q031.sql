-- q031 (group_by_rank): Which 3 sites had the lowest on-time delivery rate between January and September 2026, counting only sites with at least 50 racks reaching production in that period?
select s.site_code, count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where f.production_at >= '2026-01-01' and f.production_at < '2026-10-01'
group by 1
having count(*) >= 50
order by 2 asc
limit 3
;
