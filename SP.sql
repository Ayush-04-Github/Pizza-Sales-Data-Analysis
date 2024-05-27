create database PSales;
use Psales;
select * from orders;
select * from pizza_types;
select * from order_details;
-- Q1.Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_order
FROM
    orders

-- Q2. Calculate the total revenue generated from pizza sales. 

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
    
-- Q3 Identify the highest-priced pizza. 
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
order by pizzas.price desc
limit 1 ;

-- Q4 Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(pizzas.size) AS Pizza_sizes
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY pizzas.size
LIMIT 1;
 
 -- Q5.List the top 5 most ordered pizza types along with their quantities.
 
SELECT 
    pizza_types.name,
    COUNT(order_details.quantity) AS Quantities
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantities DESC
LIMIT 5	

-- Q6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Quantities_Ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantities_Ordered DESC

-- Q7.Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.time) AS Order_Time,
    COUNT(orders.order_id) AS Orders
FROM
    orders
GROUP BY Order_Time 

-- Q8.What is the distribution of the quantity of pizzas ordered across different hours of the day?

SELECT 
    HOUR(orders.time) AS Order_time,
    COUNT(order_details.quantity) AS Quantity_Ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY Order_time

--  Q9.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pizza_types.category AS Pizza_Categories,
    COUNT(pizza_types.name) AS Distribution
FROM
    pizza_types
GROUP BY Pizza_Categories

-- Q 10. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Quantity), 0)
FROM
    (SELECT 
        DATE(orders.date) AS Order_Date,
            SUM(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY Order_Date) AS Data

-- Q11. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name AS Pizza_Name,
    SUM(order_details.quantity * pizzas.price) AS Total
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Pizza_Name
ORDER BY Total DESC
LIMIT 3

-- Q12. Calculate the percentage contribution of each pizza type to total revenue.

	SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price) AS total_sales
                FROM
                    pizza_types
                        JOIN
                    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
                        JOIN
                    order_details ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category


--  Q13. Analyze the cumulative revenue generated over time.

select Order_Date , sum(Revenue) over(order by Order_Date ) as Cummalative_Revenue
from
(select orders.date as Order_Date, sum(order_details.quantity * pizzas.price) as Revenue
from orders join order_details on order_details.order_id = orders.order_id join pizzas on pizzas.pizza_id = order_details.pizza_id 
group by Order_Date) as subquery	

-- Q14.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select Category, NameS ,  Revenue, RN
from
(select Category ,  Names , Revenue  , rank() over ( partition by Category order by Revenue desc )as RN FROM
(select pizza_types.category as Category, pizza_types.name as Names, sum(pizzas.price * order_details.quantity) as Revenue 
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id join order_details on order_details.pizza_id = pizzas.pizza_id
group by Category, Names ) as T1)as T2
where RN<=3
