-- q001 (simple_metric): How many racks were ordered in March 2026?
select count(*) as racks_ordered
from marts.fct_rack_delivery f
where f.ordered_at >= '2026-03-01' and f.ordered_at < '2026-04-01'
;
