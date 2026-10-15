-- q010 (simple_metric): How many GPU racks reached production between January 1 and September 30, 2026?
select count(*) as racks_to_production
from marts.fct_rack_delivery f
join marts.dim_rack_type rt on f.rack_type_sk = rt.rack_type_sk
where rt.is_gpu
  and f.production_at >= '2026-01-01' and f.production_at < '2026-10-01'
;
