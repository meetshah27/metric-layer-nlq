-- q007 (simple_metric): How many racks that reached production in Q2 2026 missed their SLA?
select count(*) as sla_breach_count
from marts.fct_rack_delivery f
where f.production_at >= '2026-04-01' and f.production_at < '2026-07-01'
  and f.is_sla_breached
;
