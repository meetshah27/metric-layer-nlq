-- q027 (group_by_rank): Which rack type had the longest median burn-in time in days among racks that reached production in 2026?
select rt.rack_type_code, percentile_cont(0.5) within group (order by f.burn_in_hours) / 24.0 as median_burn_in_days
from marts.fct_rack_delivery f
join marts.dim_rack_type rt on f.rack_type_sk = rt.rack_type_sk
where f.production_at >= '2026-01-01' and f.production_at < '2027-01-01'
group by 1
order by 2 desc
limit 1
;
