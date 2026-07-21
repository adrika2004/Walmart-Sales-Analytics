create database walmart_db
use walmart_db
Select * from walmart_sales

Select payment_method, count(*) from walmart_sales
group by payment_method

Select count(distinct branch) from walmart_sales

Select min(quantity) from 

--Business problems

--Q1.Find the different payment method and number of transactions, number of quantity sold
Select payment_method,count(*) as Transactions_count,sum(quantity) as quantity_sold
from walmart_sales
group by payment_method


--Q2.Identify the highest_rated category in each branch, displaying the branch,category,AVG rating
Select * from (
Select *,
        rank() over (partition by
        branch order by avg_rating desc) as ranking
from (
select branch,category,avg(rating) as avg_rating
from walmart_sales
group by branch,category
) as t) as x
where ranking=1


--Q3.Identify the busiest day for each branch based on the number of transactions
Select * from (
Select *,
        rank() over (partition by
        branch order by no_transactions desc) as ranking
from (
select branch,
dayname(str_to_date(date,'%d/%m/%y')) as day_name,
count(*) as no_transactions
from walmart_sales
group by  branch,
dayname(str_to_date(date,'%d/%m/%y')) 
) as t) as x
where ranking=1


--Q4.Calculate the total Quantity of items sold per payment method,list payment_method and total_quantity.
Select payment_method,sum(quantity) as Quantities_Sold
from walmart_sales
group by payment_method


--Q5. Determine the average,minimum,and maximum rating of category for each city
--List the city ,average_rating,min_rating and max_rating.
Select city,category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart_sales group by city,category


--Q6.Calculate the total profit for each category  and List the category and total_profit,ordered from highest to lowest profit
Select  category,
sum(total) as total_revenue,
sum(Total*profit_margin) as profit
from walmart_sales
group by category


--Q7. Determine the most common payment method for each Branch.
--Display Branch and the preferred_payment_method
Select * from (
Select *,
        rank() over (partition by
        branch order by no_transactions desc) as ranking
from (
select branch,
payment_method,
count(*) as no_transactions
from walmart_sales
group by  branch,
payment_method
) as t) as x
where ranking=1


--Q8. Categorize sales into 3 group Morning, Afternoon,Evening
--Find out which of the shaft and number of invoices
Select 
case when hour(time)<12 then 'Morning'
when hour(time) between 12 and 17 then 'Afternoon'
else 'Evening'
end as shift,
count(invoice_id) as no_of_invoices
from walmart_sales
group by shift


--Q9. Identify 5 branch with highest decrease ratio in
--revenue compare to last year(current_year 2023 and last year 2022)
Select branch,
sum(case when year(date)=2022 then total else 0 end ) as revenue_2022,
sum(case when year(date)=2023 then total else 0 end ) as revenue_2023,
round(
((sum(case when year(date)=2022 then total else 0 end)-sum(case when year(date)=2023 then total else 0 end))/sum(case when year(date)=2022 then total else 0 end))*100,2)
as decrease_ratio
from walmart_sales
group by branch
having revenue_2023<revenue_2022
order by decrease_ratio
limit 5
 select * from walmart_sales

 
 --Q10. Top 5 branches by Revenue
 Select branch,round(sum(total),2) as total_revenue
 from walmart_sales
 group by branch
 order by total_revenue desc
 limit 5
 
 
 --Q11. Revenue Contribution (%) of each category
 Select category,
 round(sum(total),2) as revenue,
 round(sum(total)*100/(select sum(total) from walmart_sales),2) as contribution_percentage
 from walmart_sales
 group by category
 order by revenue desc
 
 
 --Q12.Highest Revenue day in every branch
 Select *
 from(
 Select branch,dayname(str_to_date(date,'%d/%m/%y')) as day_name,
 sum(total) as revenue,
 rank() over (partition by branch order by sum(total) desc) as ranking
 from walmart_sales
 group by branch,day_name)t
 where ranking =1
 
 
 --Q13.Average basket Value of each branch
 Select branch,round(avg(total),2) as average_basket_value
 from walmart_sales
 group by branch
 order by average_basket_value desc
 
 
--Q14. Most profitable Category in Every city
Select * from (
Select city,category,round(sum(total*profit_margin),2) as profit,
rank() over(partition by city order by sum(total*profit_margin) desc) as ranking
from walmart_sales
group by city,category)t
where ranking =1


--Q15. Top 10 Highest value Transactions
Select invoice_id,
branch,
city,
category,
round(total,2) as total_sales
from walmart_sales
order by total_sales desc 
limit 10


--Q16. Revenue trend by Month
Select Monthname(str_to_date(date,'%d/%m/%y')) as month_name,
round(sum(total),2) as revenue
from walmart_sales
group by month_name
order by month_name

--Q17 Running Revenue
Select 
invoice_id,
STR_TO_DATE(date,'%d/%m/%y') as sales_date,
total,
sum(total) over(order by str_to_date(date,'%d/%m/%y')) as running_revenue
from walmart_sales


--Q18. Highest rated category in every city
Select * from(
Select city,category,
round(avg(rating),2) as avg_rating,
rank() over(partition by city order by avg(rating) desc) as ranking
from walmart_sales
group by city,category)t
where ranking =1


--Q19. Branch Performance Dashboard
Select
branch,
count(*) as transactions,
round(sum(total),2) as revenue,
round(sum(total* profit_margin),2) as profit,
round(avg(rating),2) as avg_rating,
round(avg(total),2) as avg_invoice_value
from walmart_sales
group by branch
order by revenue desc


--Q20. Revenue vs ranking
Select branch,round(sum(total),2)revenue,
round(sum(total*profit_margin),2) profit,
rank()over(order by sum(total* profit_margin)desc) as profit_rank
from walmart_sales
Group by branch


--Q21.Which category contributes the highest revenue in each branch
select * from(
Select category,branch,round(sum(total),2) as revenue,
rank()over(partition by branch order by sum(total) desc) as ranking
from walmart_sales
group by branch,category)t
where ranking =1
 
 
--Q23.Find branches whose average rating is below the company average
Select branch,round(avg(rating),2) as avg_rating
from walmart_sales
group by branch
having avg(rating)<(
Select avg(rating) from walmart_sales)


--Q24.Which categories sell more units than the company average
Select category,sum(quantity) as total_quantity
from walmart_sales
group by category
having sum(quantity) > (
Select avg(total_quantity) from(
Select sum(quantity) as total_quantity
from walmart_sales
group by category)t) 


--Q25.Which branches generate more profit than the average branch profit
select branch,
round(sum(total*profit_margin),2) as profit
from walmart_sales
group by branch
having sum(total*profit_margin)>
(Select avg(profit) from(
Select sum(total*profit_margin) as profit
from walmart_sales
group by branch)t)

--Q26.Which city has the highest profit margin?
Select city,round(avg(profit_margin),2) as avg_profit_margin
from walmart_sales
group by city
order by avg_profit_margin desc limit

--Q27. Rank all branches based on customer satisfaction
Select branch,
round(avg(rating),2) as avg_rating,
dense_rank() over(order by avg(rating) desc) as ranking
from walmart_sales  group by branch
 
 
 --Q28 Which city contributes the higest perventage of total revenue?
 Select 
 city,
 round(
 sum(total),2) as revenue,
 round(
 sum(total )*100/
 (Select sum(total) from walmart_sales),2) as contribution_percentage
 from walmart_sales
 group by city
 order by contribution_percentage desc
 
 
 

