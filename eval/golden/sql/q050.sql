-- q050 (ambiguous): Are we behind?
select count(*) as overdue_open_racks
from marts.fct_rack_delivery f
where f.is_overdue_open
;
