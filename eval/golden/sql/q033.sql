-- q033 (multi_join): For vendor V03, what was the on-time delivery rate for racks ordered under each SLA version (by SLA days)?
select v.sla_days_order_to_production, count(case when not f.is_sla_breached then 1 end)::float8 / nullif(count(*), 0) as on_time_delivery_rate
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where v.vendor_code = 'V03'
  and f.production_at is not null
group by 1
;
