-- q051 (ambiguous): How busy was September?
select count(*) as racks_to_production
from marts.fct_rack_delivery f
where f.production_at >= '2026-09-01' and f.production_at < '2026-10-01'
;
