-- q045 (ratio_trap): What was the combined on-time delivery rate for vendors V01 and V02 together in 2025?
select count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where v.vendor_code in ('V01', 'V02')
  and f.production_at >= '2025-01-01' and f.production_at < '2026-01-01'
;
