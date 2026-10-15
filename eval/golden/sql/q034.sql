-- q034 (multi_join): How many racks were ordered from vendor V05 under each of its contract tiers?
select v.contract_tier, count(*) as racks_ordered
from marts.fct_rack_delivery f
join marts.dim_vendor v on f.vendor_sk = v.vendor_sk
where v.vendor_code = 'V05'
group by 1
;
