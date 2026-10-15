-- q023 (group_by_rank): Which 3 sites had the highest average install time in days for racks cabled between January and September 2026?
select s.site_code, avg(f.install_hours) / 24.0 as avg_install_days
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where f.cabled_at >= '2026-01-01' and f.cabled_at < '2026-10-01'
group by 1
order by 2 desc
limit 3
;
