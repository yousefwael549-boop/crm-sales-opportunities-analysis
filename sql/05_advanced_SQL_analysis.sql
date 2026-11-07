/*
Project: CRM Sales Opportunities Analysis
Phase: E - Advanced SQL Analysis
Purpose: Analyze sales performance through quarterly revenue growth,
sales cycle duration, regional sales agent performance,
sector revenue contribution, high-value deals, and open
opportunities. Identify revenue trends, evaluate sales
effectiveness, and understand where sales opportunities
are concentrated.
*/
use CRM
-- Quarterly Revenue Growth
with ana as
(
select 
DATETRUNC(QUARTER,close_date) as QTR,
sum(close_value) as revenue
from sales_pipeline
where deal_stage='won'
and close_value is not null
group by DATETRUNC(QUARTER,close_date)
)
select 
QTR,
revenue,
lag(revenue) over(order by QTR) as prev_qtr_revenue,
round(
	cast(
	(revenue-lag(revenue) over(order by QTR)) as float)
	/nullif(
	lag(revenue) over(order by QTR),0) * 100,3)
	as QTR_growth
from ana 
--Sales Cycle Analysis
select 
avg(
	case 
	when deal_stage='won'
	then DATEDIFF(day,engage_date,close_date) end) as won_deals_cycle,
avg(
	case 
	when deal_stage='lost'
	then datediff(day,engage_date,close_date) end) as lost_deal_cycle
from sales_pipeline
--Top 3 Agents per Region
with data as 
(
select 
s.sales_agent,
office_location,
sum(close_value) as total_revenue
from sales_pipeline s join accounts a
on s.account=a.account
where close_value is not null
group by s.sales_agent,
office_location
)
select 
office_location , sales_agent , total_revenue , revenue_rank
from (
	select 
		office_location ,
		sales_agent ,
		total_revenue ,
		row_number() over(partition by office_location order by total_revenue desc) as revenue_rank from data )
as newtable
where revenue_rank <= 3
--Eeach Sector Revenue Contribution%
with data as
(
select 
a.sector,
sum(close_value) as total_revenue
from accounts a left join sales_pipeline s
on s.account=a.account
where close_value is not null
group by a.sector
),data_aggregations as 
(
select 
sector,
total_revenue,
sum(total_revenue) over() as overall_revenue
from data
)
select 
sector,
total_revenue,
round(
	cast(total_revenue as float)/overall_revenue*100, 3) as contribution
from data_aggregations
order by total_revenue desc
--High-Value Deals
-----deals with close values above average
select *
from sales_pipeline
where close_value >
(select avg(close_value) from sales_pipeline where deal_stage='won')
-----top 10 deals by close value
select 
top(10) * 
from sales_pipeline
order by close_value desc
--open pipelines analysis 
-----total open opportunities
select 
count(distinct opportunity_id) as open_opportunities 
from sales_pipeline
where deal_stage='prospecting' 
or deal_stage='engaging'
-----accounts by open opportunities
select 
a.account,
count(distinct opportunity_id) as open_opportunities
from accounts a left join sales_pipeline s
on a.account=s.account
where deal_stage='prospecting'
or deal_stage='engaging'
group by a.account
order by open_opportunities desc
------sectors by open opportunities
select 
a.sector,
count(distinct opportunity_id) as open_opportunities
from accounts a left join sales_pipeline s
on a.account=s.account
where deal_stage='prospecting'
or deal_stage='engaging'
group by a.sector
order by open_opportunities desc
