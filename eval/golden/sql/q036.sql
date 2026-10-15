-- q036 (multi_join): At us-west sites, what was the average order-to-production time in days for GPU versus non-GPU racks that reached production between January and September 2026?
select rt.is_gpu, avg(f.end_to_end_hours) / 24.0 as avg_end_to_end_days
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
join marts.dim_rack_type rt on f.rack_type_sk = rt.rack_type_sk
where s.site_region = 'us-west'
  and f.production_at >= '2026-01-01' and f.production_at < '2026-10-01'
group by 1
;
