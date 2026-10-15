-- q051 alternative (ordered): How busy was September?
select count(*) as racks_ordered
from marts.fct_rack_delivery f
where f.ordered_at >= '2026-09-01' and f.ordered_at < '2026-10-01'
;
