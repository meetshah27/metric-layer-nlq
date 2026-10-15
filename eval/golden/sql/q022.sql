-- q022 (time_window): What was the average install time in days for each month of the first half of 2026?
select date_trunc('month', f.cabled_at) as month, avg(f.install_hours) / 24.0 as avg_install_days
from marts.fct_rack_delivery f
where f.cabled_at >= '2026-01-01' and f.cabled_at < '2026-07-01'
group by 1
;
