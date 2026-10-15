-- q042 (ratio_trap): What was the overall regression rate across all sites for racks that reached production in 2025?
select count(case when f.regression_count > 0 then 1 end)::float8 / nullif(count(*), 0) as burn_in_regression_rate
from marts.fct_rack_delivery f
where f.production_at >= '2025-01-01' and f.production_at < '2026-01-01'
;
