-- q049 alternative (lead): Which vendor is the slowest?
select v.vendor_code, avg(f.vendor_lead_hours) / 24.0 as avg_vendor_lead_days
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where f.shipped_at >= '2026-09-01' and f.shipped_at < '2026-10-01'
group by 1
order by 2 desc
limit 1
;
