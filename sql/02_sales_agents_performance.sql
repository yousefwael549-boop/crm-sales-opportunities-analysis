use CRM
/*
Project: CRM Sales Opportunities Analysis
Phase: B - Sales Team Performance
Purpose: Evaluate sales agent performance by analyzing won revenue,
the number of won deals, and win rate. Rank sales agents
based on these KPIs to identify top performers and understand
differences in sales results.
*/
--Agents Revenue
select 
st.sales_agent,
sum(close_value) as total_revenue
from sales_teams st left join sales_pipeline sp 
on st.sales_agent=sp.sales_agent
where deal_stage='won'
group by st.sales_agent
--total won deals For Each Agent
select
st.sales_agent,
sum(case when deal_stage='won'
then 1 else 0 end) total_wins
from sales_teams st left join sales_pipeline sp
on st.sales_agent = sp.sales_agent
group by st.sales_agent
--Agent Ranking By Revenue
with agents_revenue as
(
select 
sales_agent,
sum(close_value) as total_revenue
from sales_pipeline
where deal_stage='won'
group by sales_agent
) 
select 
sales_agent ,
total_revenue , 
revenue_rank
from(select sales_agent, total_revenue , dense_rank() over(order by total_revenue desc
) as revenue_rank from agents_revenue ) as newtable
--Agent Ranking By Won Deals
with agents_won_deals as 
(
select 
sales_agent,
count(distinct opportunity_id) as won_deals
from sales_pipeline
where deal_stage='won'
group by sales_agent
)
select sales_agent,won_deals,won_deals_rank
from(select 
sales_agent , 
won_deals ,
DENSE_RANK() over(order by won_deals desc) as won_deals_rank from agents_won_deals)
as newtable
--Ranking Agents By Average Order Value
with Agents_AOV as 
(
select 
sales_agent,
round(cast(sum(close_value) as float)
/
sum(
case when deal_stage='won'
or deal_stage='lost'
then 1 else 0 end),2) AOV
from sales_pipeline
group by sales_agent
)
select sales_agent,AOV,Ranking_AOV
from(select sales_agent,AOV,DENSE_RANK() over(order by AOV desc) as Ranking_AOV from Agents_AOV)
as newtable
--Agent Ranking By Win Rate
with data_aggregations as
(
select 
sales_agent,
sum(
case when deal_stage='won'
then 1 else 0 end) as total_won,
sum(
case when deal_stage='won' 
or deal_stage='lost'
then 1 else 0 end ) as closed_deals
from sales_pipeline
group by sales_agent
)
select 
sales_agent,total_won,closed_deals,win_rate, win_rate_rank
from 
(select sales_agent,
total_won,
closed_deals,
cast(total_won as float)/closed_deals*100.0 as win_rate,
dense_rank() over(order by cast(total_won as float) 
/
nullif(closed_deals,0) *100.0 desc) as win_rate_rank from data_aggregations)
as newtable

