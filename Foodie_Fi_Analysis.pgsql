select * from plans
 select * from subscriptions

--Total No. of Customers
select  count(distinct customer_id) as Total_Cust 
from subscriptions

--Take random 8 samples and display the stats of Foddie_FI
with cte as(
select customer_id,plans.plan_name,start_date from subscriptions
join plans on subscriptions.plan_id=plans.plan_id
group by 1,2,3
order by start_date asc
)
select * from cte 
where customer_id in(
    1,20,100,200,350,500,680,800
)

--Monthly Distribution of trial plan :
select extract(MONTH from start_date) as month_1,count(distinct customer_id) as total_cust,p.plan_name from subscriptions
join plans p on subscriptions.plan_id=p.plan_id
where plan_name='trial'
GROUP by month_1,3

--The Count and Percentage of Customer who has 'Churn' plan
select count(DISTINCT
     CASE
     when p.plan_name='churn' then s.customer_id
     end) as churn_count,

count(distinct s.customer_id) as total_count,
((count(DISTINCT
     CASE
     when p.plan_name='churn' then s.customer_id
     end))/(count(distinct s.customer_id)))*100 as churn_rate
from subscriptions s
join plans p on s.plan_id=p.plan_id


--2021 Distribution of Plans and its count
select extract(YEAR from start_date) as Events,p.plan_name,count(*) as Plan_Count from subscriptions s
join plans p on s.plan_id=p.plan_id
GROUP by 1,2
HAVING extract(YEAR from start_date)='2021'
order by Plan_Count desc


--Count of customer upgraded to annual plan in 2020.
select count(DISTINCT customer_id) as total_cust from subscriptions
join plans on subscriptions.plan_id=plans.plan_id
where plan_name='pro annual' and extract(YEAR from start_date)='2020'

--No. of cust. downgraded their plan from pro monthly to basic monthly
with nextplan as(
     select s.customer_id,s.start_date,p.plan_id,extract(year from start_date) as year_1,     
	lead(p.plan_name) over(PARTITION by customer_id order by start_date) as next_plan
     from subscriptions s
join plans p on s.plan_id=p.plan_id
	group by 1,2,3,p.plan_name
)
select count(*) as pro_to_basic_monthly
from nextplan,plans
where plan_name='pro monthly' and  next_plan='basic monthly'
and extract(year from start_date)='2020'

--how many customer has churn just after the initial_free_trial plan and at what percentage.
with cte as(
     select s.customer_id,s.start_date,p.plan_name,     
	lead(p.plan_name) over(PARTITION by customer_id order by start_date) as le
     from subscriptions s
join plans p on s.plan_id=p.plan_id
	group by 1,2,3
)
select count(*) as count_trial_churn,round(count(*)/(select count(distinct customer_id) from subscriptions),2)*100 as percentage
from cte
where plan_name='trial' and  le='churn'








