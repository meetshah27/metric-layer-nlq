-- avg_install_days: Mean RECEIVED to CABLED days, by cabled month. Per rack, never an average of group averages.
-- Matches: mf query --metrics avg_install_days --group-by metric_time__month
select
    date_trunc('month', cabled_at) as month,
    avg(install_hours / 24.0) as avg_install_days
from marts.fct_rack_delivery
where cabled_at is not null
group by 1
order by 1
;
