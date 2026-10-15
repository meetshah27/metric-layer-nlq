-- q048 alternative (avg): How fast are racks getting to production?
select avg(f.end_to_end_hours) / 24.0 as avg_end_to_end_days
from marts.fct_rack_delivery f
where f.production_at >= '2026-09-01' and f.production_at < '2026-10-01'
;
