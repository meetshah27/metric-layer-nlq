-- q029 (group_by_rank): Which 5 racks not yet in production have been stuck in their current status the longest? Show rack id, status and days in status.
select f.rack_id, f.current_status, f.days_in_current_status
from marts.fct_rack_delivery f
where f.production_at is null and f.decommissioned_at is null
order by f.days_in_current_status desc
limit 5
;
