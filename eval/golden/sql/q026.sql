-- q026 (group_by_rank): Which 5 sites currently have the most racks in flight?
select s.site_code, count(*) as racks_in_flight
from marts.fct_rack_delivery f
join marts.dim_site s on f.site_sk = s.site_sk
where f.production_at is null and f.decommissioned_at is null
group by 1
order by 2 desc
limit 5
;
