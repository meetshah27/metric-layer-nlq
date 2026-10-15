-- q038 (multi_join): Of the racks ordered from V02 under its 55-day SLA that have reached production, what share would have been late under its earlier 50-day SLA?
select count(case when f.end_to_end_hours > 50 * 24 then 1 end)::float8 / nullif(count(*), 0) as share_late_under_50_day_sla
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where v.vendor_code = 'V02'
  and v.sla_days_order_to_production = 55
  and f.production_at is not null
;
