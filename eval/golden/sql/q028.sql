-- q028 (group_by_rank): For each vendor with at least one currently overdue open rack, how many overdue racks do they have? Sort from most to least.
select v.vendor_code, count(*) as overdue_open_racks
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where f.is_overdue_open
group by 1
order by 2 desc
;
