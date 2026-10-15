-- q049 alternative (avg): Which vendor is the slowest?
select v.vendor_code, avg(f.end_to_end_hours) / 24.0 as avg_end_to_end_days
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where f.production_at >= '2026-09-01' and f.production_at < '2026-10-01'
group by 1
order by 2 desc
limit 1
;
