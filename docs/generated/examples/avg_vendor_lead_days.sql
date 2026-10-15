-- avg_vendor_lead_days: Mean ORDERED to SHIPPED days, by ship month. Per rack, never an average of group averages.
-- Matches: mf query --metrics avg_vendor_lead_days --group-by metric_time__month
select
    date_trunc('month', shipped_at) as month,
    avg(vendor_lead_hours / 24.0) as avg_vendor_lead_days
from marts.fct_rack_delivery
where shipped_at is not null
group by 1
order by 1
;
