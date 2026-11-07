/*
Project: CRM Sales Opportunities Analysis
Phase: D - Accounts Performance Analysis
Purpose: Analyze sales performance across customer accounts by examining
won revenue, opportunity volume, win rate, and average winning
deal value for each account.
*/
use CRM
select * from sales_pipeline
select * from accounts
--Revenue By Sector
select 
sector,
sum(close_value) as total_revenue
from accounts a left join sales_pipeline s
on a.account=s.account
group by sector
--accounts_with_won_deals
select 
count(distinct account) as converted_accounts
from sales_pipeline
where deal_stage='won'
--Average Deal Value By Sector
select 
	sector,
	round(
	cast(
	sum(close_value) as float)
	/
	count(opportunity_id),2) as avg_won_deal_value
from accounts a join sales_pipeline s
on a.account=s.account
where deal_stage='won'
group by sector
--Ranking Sectors by revenue & Win Rate
with sector_rank as 
(
select
a.sector,
sum(close_value) as total_revenue,
cast(count(distinct 
	case when deal_stage='won' then s.opportunity_id end) as float)
	/
count(distinct case when deal_stage='won' or deal_stage='lost' then s.opportunity_id end) *100.0 as win_rate
from accounts a join sales_pipeline s
on a.account=s.account
group by a.sector
)
select 
sector , total_revenue, win_rate , revenue_rank
from (
select sector ,
total_revenue ,
win_rate ,
DENSE_RANK() over(order by total_revenue desc) as revenue_rank from sector_rank)
as newtable