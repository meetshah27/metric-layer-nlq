-- q003 (simple_metric): What was the on-time delivery rate for vendor V03 in August 2026?
select count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where v.vendor_code = 'V03'
  and f.production_at >= '2026-08-01' and f.production_at < '2026-09-01'
;
