-- q050 alternative (breaches): Are we behind?
select count(*) as sla_breach_count
from marts.fct_rack_delivery f
where f.production_at >= '2026-09-01' and f.production_at < '2026-10-01'
  and f.is_sla_breached
;
