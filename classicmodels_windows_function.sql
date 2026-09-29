-- WINDOWS FUNCTIONS

/*Name	Description
CUME_DIST()	Cumulative distribution value
DENSE_RANK()	Rank of current row within its partition, without gaps
FIRST_VALUE()	Value of argument from first row of window frame
LAG()	Value of argument from row lagging current row within partition
LAST_VALUE()	Value of argument from last row of window frame
LEAD()	Value of argument from row leading current row within partition
NTH_VALUE()	Value of argument from N-th row of window frame
NTILE()	Bucket number of current row within its partition.
PERCENT_RANK()	Percentage rank value
RANK()	Rank of current row within its partition, with gaps
ROW_NUMBER()	Number of current row within its partition */

-- 1
select customerNumber, creditLimit,
ROW_NUMBER() OVER (ORDER BY creditLimit DESC) as `row_number`,
RANK() OVER (ORDER BY creditLimit DESC) as `rank`,
DENSE_RANK() OVER (ORDER BY creditLimit DESC) as `dense_rank`,
NTILE(4)  OVER (ORDER BY creditLimit DESC) as `cust_ntile`,
LAG(creditLimit,1) OVER (ORDER BY creditLimit DESC) as `lag`,
LEAD(creditLimit,1) OVER (ORDER BY creditLimit DESC) as `lead`,
CUME_DIST() OVER (ORDER BY creditLimit DESC) as `cume_dist`
from classicmodels.customers
order by creditLimit desc, customerNumber asc;

-- 2
select country, creditLimit,
FIRST_VALUE(creditLimit) OVER(PARTITION BY country ORDER BY country) as `first_value`,
LAST_VALUE(creditLimit) OVER(PARTITION BY country ORDER BY country) as `last_value`,
AVG(creditLimit) OVER (PARTITION BY country) as `avg`,
MIN(creditLimit) OVER (PARTITION BY country) as `min`,
MAX(creditLimit) OVER (PARTITION BY country) as `max`
from classicmodels.customers
group by country, creditLimit;

-- 3.rank customers by credit limit -- Ранжируйте клиентов по кредитному лимиту.

select customerNumber, creditLimit,
RANK() OVER (ORDER BY creditLimit DESC) as `rank`
from classicmodels.customers
order by creditLimit desc, customerNumber asc;

-- 4.list the most sold product by city -- Перечислите наиболее продаваемые товары по городам.

select * from
(select 
	c.city, 
	p.productName, 
	sum(od.quantityOrdered) as quantityOrdered,
	RANK() OVER (PARTITION BY c.city ORDER BY sum(od.quantityOrdered) DESC) as `rank`
from classicmodels.products p
join classicmodels.orderdetails od on od.productCode = p.productCode
join classicmodels.orders o on o.orderNumber = od.orderNumber
join classicmodels.customers c on c.customerNumber = o.customerNumber
group by p.productName, c.city) a
where `rank` = 1
order by a.quantityOrdered desc;

USE `classicmodels`;

-- 5 Кумулятивная выручка по датам
SELECT 
     o.orderDate,
     c.customerNumber,
     c.customerName,
    SUM(od.quantityOrdered * od.priceEach) as order_amount,
    SUM(SUM(od.quantityOrdered * od.priceEach)) 
        OVER (PARTITION BY c.customerNumber ORDER BY o.orderDate 
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cumulative_revenue,
    NTILE(4) OVER (PARTITION BY c.customerNumber ORDER BY o.orderDate) as revenue_quartile
FROM orders o
JOIN customers c -- ON o.customerNumber = c.customerNumber
USING(customerNumber)
JOIN orderdetails od -- ON o.orderNumber = od.orderNumber
USING(orderNumber)
GROUP BY o.orderNumber
ORDER BY c.customerNumber, o.orderDate;

-- 6 Топ-продукты с долей от заказа
SELECT 
   od.orderLineNumber,
    od.orderNumber,
    p.productName,
    od.quantityOrdered,
    od.priceEach,
    od.quantityOrdered * od.priceEach as line_total,
    SUM(od.quantityOrdered * od.priceEach) OVER (PARTITION BY od.orderNumber) as order_total,
    (od.quantityOrdered * od.priceEach / SUM(od.quantityOrdered * od.priceEach) 
     OVER (PARTITION BY od.orderNumber)) * 100 as line_share_pct,
    LAG(p.productName) OVER (PARTITION BY od.orderNumber ORDER BY od.orderLineNumber) as prev_product
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
ORDER BY od.orderNumber, od.orderLineNumber;

-- 7 Рейтинг сотрудников по выручке в офисе по кварталам.
WITH quarterly_sales AS (
    SELECT 
        e.employeeNumber, e.officeCode,
        e.lastName,
        DATE_FORMAT(o.orderDate, '%Y-Q') as quarter,
        SUM(od.quantityOrdered * od.priceEach) as qtr_revenue
    FROM employees e 
    JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
    JOIN orders o ON c.customerNumber = o.customerNumber
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    GROUP BY e.employeeNumber, quarter
),
leaderboard AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY officeCode, quarter
            ORDER BY qtr_revenue DESC, employeeNumber  -- выручка + ID стабильность
            ROWS UNBOUNDED PRECEDING
        ) as qtr_rank,
        AVG(qtr_revenue) OVER (
            PARTITION BY officeCode, quarter
            ORDER BY qtr_revenue DESC, employeeNumber
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as qtr_avg_revenue
    FROM quarterly_sales
)
SELECT * FROM leaderboard 
WHERE qtr_rank <= 3
ORDER BY officeCode, quarter, qtr_rank;


-- 8. Клиентская сегментация по PERCENT_RANK (RFM). Разделить клиентов на квинтили по выручке внутри страны менеджера.
	WITH customer_revenue AS (
	    SELECT 
	        c.customerName, c.country, c.salesRepEmployeeNumber,
	        SUM(od.quantityOrdered * od.priceEach) as totalRevenue,
	        COUNT(o.orderNumber) as orderCount,
	        DATEDIFF(MAX(o.orderDate), MIN(o.orderDate)) as customer_lifetime_days -- Длительность "жизни" клиента — количество дней между ПЕРВЫМ и ПОСЛЕДНИМ заказом. 
	        -- "возраст клиента в днях активности" — ключ для RFM(F), когорт, сегментации лояльности 
	    FROM customers c 
	    JOIN orders o ON c.customerNumber = o.customerNumber
	    JOIN orderdetails od ON o.orderNumber = od.orderNumber
	    GROUP BY c.customerNumber
	)
SELECT 
	    customerName, country, salesRepEmployeeNumber,
	    totalRevenue,
	    -- Перцентиль выручки в стране менеджера
	    PERCENT_RANK() OVER (
	        PARTITION BY salesRepEmployeeNumber, country
	        ORDER BY totalRevenue DESC
	    ) as revenue_percentile,
	    -- Квинтиль по lifetime
	    NTILE(5) OVER (
	        PARTITION BY salesRepEmployeeNumber
	        ORDER BY customer_lifetime_days DESC
	    ) as loyalty_quintile
	FROM customer_revenue
	ORDER BY salesRepEmployeeNumber, country, totalRevenue DESC;
	-- Логика: PERCENT_RANK() = 0.8 значит клиент в топ-20% по выручке среди коллег в стране. NTILE(5) = равные группы по лояльности.