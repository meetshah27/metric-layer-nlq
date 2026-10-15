-- q030 (group_by_rank): Which vendor had the highest average transit time in days for racks received in 2026?
select v.vendor_code, avg(f.transit_hours) / 24.0 as avg_transit_days
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where f.received_at >= '2026-01-01' and f.received_at < '2027-01-01'
group by 1
order by 2 desc
limit 1
;
