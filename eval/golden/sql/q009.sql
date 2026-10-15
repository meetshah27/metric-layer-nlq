-- q009 (simple_metric): What was the average install time in days at FRA-01 for racks cabled in September 2026?
select avg(f.install_hours) / 24.0 as avg_install_days
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where s.site_code = 'FRA-01'
  and f.cabled_at >= '2026-09-01' and f.cabled_at < '2026-10-01'
;
