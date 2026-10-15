-- q043 (ratio_trap): What was the combined on-time delivery rate for all us-east sites in Q2 2026?
select count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where s.site_region = 'us-east'
  and f.production_at >= '2026-04-01' and f.production_at < '2026-07-01'
;
