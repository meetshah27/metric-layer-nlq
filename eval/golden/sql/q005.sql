-- q005 (simple_metric): How many racks are currently overdue and not yet in production?
select count(*) as overdue_open_racks
from marts.fct_rack_delivery f
where f.is_overdue_open
;
