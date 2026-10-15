-- q037 (multi_join): How many status regressions occurred at each site between January and September 2026?
select s.site_code, count(*) as regressions
from marts.fct_rack_status_event e
join marts.dim_site s on e.site_sk = s.site_sk
where e.is_regression
  and e.event_at >= '2026-01-01' and e.event_at < '2026-10-01'
group by 1
;
