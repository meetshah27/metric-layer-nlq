-- q039 (multi_join): Which sites received racks from all 6 vendors in 2025?
select s.site_code
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where f.received_at >= '2025-01-01' and f.received_at < '2026-01-01'
group by 1
having count(distinct v.vendor_code) = 6
;
