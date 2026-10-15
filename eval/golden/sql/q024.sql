-- q024 (group_by_rank): Rank all vendors by on-time delivery rate for racks that reached production in 2025.
select v.vendor_code, count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where f.production_at >= '2025-01-01' and f.production_at < '2026-01-01'
group by 1
order by 2 desc
;
