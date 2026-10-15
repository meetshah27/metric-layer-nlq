-- q035 (multi_join): What was the on-time delivery rate by vendor contract tier, using the tier in effect when each rack was ordered, for racks reaching production between January and September 2026?
select v.contract_tier, count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where f.production_at >= '2026-01-01' and f.production_at < '2026-10-01'
group by 1
;
