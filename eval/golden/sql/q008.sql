-- q008 (simple_metric): What was the average vendor lead time in days for vendor V01, for racks shipped in 2025?
select avg(f.vendor_lead_hours) / 24.0 as avg_vendor_lead_days
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where v.vendor_code = 'V01'
  and f.shipped_at >= '2025-01-01' and f.shipped_at < '2026-01-01'
;
