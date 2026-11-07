use CRM
/*
Project: CRM Sales Opportunities Analysis
Phase: A - Overall Sales Performance
Purpose: Calculate the core sales KPIs.
*/
--Total revenue from winning deals
select 
sum(close_value) as revenue_from_won_deals
from sales_pipeline
where deal_stage='won'
--total opportunities
select 
count(distinct opportunity_id) as total_opportunities
from sales_pipeline
--won deals
select 
count(distinct opportunity_id) as won_deals
from sales_pipeline
where deal_stage='won'
--lost deals 
select 
count(distinct opportunity_id) as lost_deals
from sales_pipeline
where deal_stage='lost'
--Win Rate
select 
	concat(
	round(
	cast(
	(select 
	count(opportunity_id) 
	from sales_pipeline 
	where deal_stage='won') as float) 
	/
	count(opportunity_id) *100.0 ,2),'%')
	from sales_pipeline
	where deal_stage='won' or deal_stage='lost'
--Average Winning Deal
select 
round(cast(sum(close_value) as float)
/
nullif(count(opportunity_id),0),2) as avg_won_deal_value
from sales_pipeline
where deal_stage='won'
--Monthly Revenue & Growth
with current_month as 
(
select 
DATETRUNC(month,close_date) as month,
sum(close_value) as current_month_revenue
from sales_pipeline
where close_date is not null 
and deal_stage='won'
group by DATETRUNC(month,close_date)
), data_aggregations as
(
select 
month,
current_month_revenue,
lag(current_month_revenue) over(order by month) as prev_month_revenue
from current_month
)
select 
month,
current_month_revenue,
prev_month_revenue,
concat(round((cast((current_month_revenue - prev_month_revenue) as float)/nullif(prev_month_revenue,0))*100,2),'%')
from data_aggregations




