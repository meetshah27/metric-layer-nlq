-- q020 (time_window): How many racks have been ordered year to date, compared with the same period last year? Return the year and the count.
select extract(year from f.ordered_at) as year, count(*) as racks_ordered
from marts.fct_rack_delivery f
where (f.ordered_at >= '2025-01-01' and f.ordered_at < '2025-10-01')
   or (f.ordered_at >= '2026-01-01' and f.ordered_at < '2026-10-01')
group by 1
;
