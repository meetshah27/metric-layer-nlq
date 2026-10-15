-- q016 (time_window): How many racks were ordered in the trailing 90 days?
select count(*) as racks_ordered
from marts.fct_rack_delivery f
where f.ordered_at >= '2026-07-03' and f.ordered_at < '2026-10-01'
;
