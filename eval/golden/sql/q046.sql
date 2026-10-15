-- q046 (ratio_trap): What was the overall average order-to-production time in days for all GPU racks that reached production between January and September 2026?
select avg(f.end_to_end_hours) / 24.0 as avg_end_to_end_days
from marts.fct_rack_delivery f
join marts.dim_rack_type rt on f.rack_type_sk = rt.rack_type_sk
where rt.is_gpu
  and f.production_at >= '2026-01-01' and f.production_at < '2026-10-01'
;
