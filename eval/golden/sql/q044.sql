-- q044 (ratio_trap): What was the overall average install time in days across all sites for racks cabled between January and September 2026?
select avg(f.install_hours) / 24.0 as avg_install_days
from marts.fct_rack_delivery f
where f.cabled_at >= '2026-01-01' and f.cabled_at < '2026-10-01'
;
