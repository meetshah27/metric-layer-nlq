-- q032 (group_by_rank): In each region, which site had the most racks reach production in 2025?
with site_counts as (
    select s.site_region, s.site_code, count(*) as racks_to_production
    from marts.fct_rack_delivery f
    join marts.dim_site s on f.site_sk = s.site_sk
    where f.production_at >= '2025-01-01' and f.production_at < '2026-01-01'
    group by 1, 2
),
ranked as (
    select site_region, site_code, racks_to_production,
           rank() over (partition by site_region order by racks_to_production desc) as rnk
    from site_counts
)
select site_region, site_code, racks_to_production
from ranked
where rnk = 1
;
