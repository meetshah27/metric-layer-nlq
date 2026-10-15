-- q002 (simple_metric): How many racks reached production at site SEA-02 in July 2026?
select count(*) as racks_to_production
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where s.site_code = 'SEA-02'
  and f.production_at >= '2026-07-01' and f.production_at < '2026-08-01'
;
