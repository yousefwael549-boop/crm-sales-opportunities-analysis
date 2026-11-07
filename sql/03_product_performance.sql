/*
Project: CRM Sales Opportunities Analysis
Phase:  C - Product Performance Analysis
Purpose: Evaluate product performance by analyzing won revenue,
opportunity volume, win rate, and average winning deal value.
Rank products based on revenue generated from won deals
to identify high-performing products and understand differences
in product sales performance.
*/
use CRM
select * from sales_pipeline
select * from products
--Revenue And Orders For Each Product
select 
p.product,
sum(close_value) as total_revenue,
count(distinct opportunity_id) as total_opportunities
from products p left join sales_pipeline s 
on p.product=s.product
group by p.product
--Win Rate for Each Product
select 
p.product,
round(cast(sum(case when deal_stage='won' then 1 else 0 end) as float)
/
nullif(sum(case when deal_stage='won' or deal_stage='lost' then 1 else 0 end),0),3) as win_rate
from products p left join sales_pipeline s
on p.product=s.product
group by p.product
--AOV for Each Product
select
p.product,
round(cast(sum(close_value) as float)
/
nullif(sum(case when deal_stage='won'
then 1 else 0 end),0),2) as AOV
from products p left join sales_pipeline s 
on p.product=s.product
group by p.product
--Ranking Products By Revenue
with data as
(
select
opportunity_id,
p.product,
deal_stage,
close_value,
sales_price as unit_price
from sales_pipeline s left join products p 
on p.product=s.product
)
select 
    product,
    unit_price,
    sum(close_value) as total_revenue,
    sum(
        case when deal_stage='won'
        or deal_stage='lost'
        then 1 else 0 end) as Total_Opportunitities,
    sum(
        case when deal_stage='won'
        then 1 else 0 end) as Won_Deals,
    sum(
        case when deal_stage='lost'
        then 1 else 0 end) as Lost_Deals,
        round(
        cast(
        sum(
            case when deal_stage='won'
            then 1 else 0 end)as float)
         /
        nullif(
        sum(
            case when deal_stage='won'
            or deal_stage='lost'
            then 1 else 0 end),0), 3) as win_rate,
        round(
        cast(
        sum(close_value) as float)
        /
        nullif(
        sum(
        case when deal_stage='won'
        then 1 else 0 end),3),0) as AOV
from data
group by product,unit_price
order by total_revenue desc
