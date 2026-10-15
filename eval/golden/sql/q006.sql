-- q006 (simple_metric): How many racks are currently in flight, meaning ordered but not yet in production?
select count(*) as racks_in_flight
from marts.fct_rack_delivery f
where f.production_at is null
  and f.decommissioned_at is null
;
