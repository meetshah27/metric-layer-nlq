-- racks_ordered: Racks with an order placed, by order month.
-- Matches: mf query --metrics racks_ordered --group-by metric_time__month
select
    date_trunc('month', ordered_at) as month,
    count(rack_id) as racks_ordered
from marts.fct_rack_delivery
where ordered_at is not null
group by 1
order by 1
;
