-- q040 (multi_join): For vendor V04 racks, what was the average number of hours between consecutive status events, by status, for events in 2026?
select e.status, avg(e.hours_since_prev_event) as avg_hours_since_prev_event
from marts.fct_rack_status_event e
join marts.dim_vendor v on e.vendor_sk = v.vendor_sk
where v.vendor_code = 'V04'
  and e.event_at >= '2026-01-01' and e.event_at < '2027-01-01'
group by 1
;
