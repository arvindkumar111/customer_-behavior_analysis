select * from customer limit 10;
ALTER TABLE customer RENAME COLUMN "purchase_amount_(usd)" TO purchase_amount;



-- Q1. what is the total revenue genrated by male vs female customer

select gender,sum(purchase_amount) as revenue 
from customer
group by gender;

-- Q2. which customer used a discount and still pays more than average purchase amount

select customer_id,purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount >=(select avg(purchase_amount) from customer);


--Q3 which are the top 5 product with highest review rating

select item_purchased,round(avg(review_rating::numeric),2)
from customer 
group by item_purchased
order by avg(review_rating)
desc limit 5;

--Q4 compare the average purchase amount between standard and express shipping

select shipping_type,avg(purchase_amount) as avg_purchase from customer
where shipping_type in ('Standard','Express')
group by shipping_type;


-- Q5 do subscribed customer spend more? compare average spend and  total revenue between subscriber and non subscriber

select subscription_status, avg(purchase_amount) , sum(purchase_amount) from customer
group by subscription_status;

-- Q6 which 5 product have highest percentage of purchase with discounts applied
select item_purchased , round(100*sum(case when discount_applied = 'Yes' then 1 else 0 end )/count(*),2) as percent_rate 
from customer
group by item_purchased
order by percent_rate
desc limit 5

-- Q7 segment customers into New,Returning, and Loyal based on their total
-- number of previous purchases, and show the count of each segment

with cte as (
select customer_id,
case
when previous_purchases = 1 then 'New'
when previous_purchases between 3 and 15 then 'Returning'
else 'Loyal based'
end as segment
from customer
)
select segment,count(*) from cte
group by segment

-- Q8 what are the top 3 most purchased products with each category?
with item_counts as (
select category,
item_purchased,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased
)
select item_rank,category, item_purchased,total_orders
from item_counts
where item_rank <=3;

-- Q9 Are customers who are repeat buyers(more than previous purchases) are also likely to subscribe?
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status
-- Q10 what is the revenue contribution of each age group?

select age_group,
sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;


