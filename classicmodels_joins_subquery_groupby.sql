-- these questions require table joins and group by 
-- 1 how many vendors, product lines, and products exist in the database? -- 10. Сколько поставщиков, товарных линий и товаров существует в базе данных?
SELECT 
	COUNT(*) as product_count, 
	COUNT(distinct productVendor) as vendor_count, 
    COUNT(distinct productLine) as productLine_count 
FROM classicmodels.products;

-- 2 what is the average price (buy price, MSRP) per vendor? --11. Какова средняя цена (цена покупки, MSRP) у каждого поставщика?
SELECT 
	productVendor, 
    round(AVG(MSRP), 2) as MSRP_avg
FROM classicmodels.products
group by productVendor
order by MSRP_avg;

-- 3 what is the average price (buy price, MSRP) per customer? --12. Какова средняя цена (цена покупки, MSRP) на одного клиента?

SELECT 
	c.customerNumber, 
    c.customerName, 
    ROUND(AVG(p.buyPrice), 2) as avg_buyPrice_by_customer, 
    ROUND(AVG(p.MSRP), 2) as avg_MSRP_by_customer 
FROM classicmodels.customers c
	JOIN classicmodels.orders o ON o.customerNumber = c.customerNumber 
	JOIN classicmodels.orderdetails od ON od.orderNumber = o.orderNumber
	JOIN classicmodels.products p ON p.productCode = od.productCode
GROUP BY c.customerNumber
ORDER BY c.customerNumber ASC;

-- 4 what product was sold the most? --13. Какой товар был продан больше всего?
SELECT 
	p.productCode, 
    SUM(od.quantityOrdered) as quantityOrdered
FROM classicmodels.products p
JOIN classicmodels.orderdetails od on od.productCode = p.productCode
group by p.productCode
order by quantityOrdered desc
limit 3;

-- 5 how much money was made between buyPrice and MSRP? --14. Сколько денег было заработано между ценой покупки и MSRP?
-- Найти разницу (MRSP - ByPrice) * на количество проданных единиц, и просуммировать по всем товарам
SELECT 
	p.productCode, 
	p.productName, 
	SUM((p.MSRP - p.buyPrice)*od.quantityOrdered) as sales_revenue
FROM classicmodels.products p
JOIN classicmodels.orderdetails od on od.productCode = p.productCode
group by p.productCode
order by sales_revenue;

-- 6 which vendor sells more products? --15. Какой поставщик продает больше товаров?
SELECT 
	p.productVendor, 
	SUM(od.quantityOrdered) as total_quantityOrdered_products,
    count(od.productcode) as quantity_productcodes
FROM classicmodels.products p
JOIN classicmodels.orderdetails od on od.productCode = p.productCode
group by p.productVendor
order by total_quantityOrdered_products desc
limit 1;

-- 7 show all customer names with employees in San Francisco office
-- вариант 1 - join
SELECT c.customerName, 
	CONCAT(emp.firstName, ' ', emp.lastName) as employees_name,
	o.city
FROM classicmodels.customers c
JOIN classicmodels.employees emp on emp.employeeNumber = c.salesRepEmployeeNumber
JOIN classicmodels.offices o on o.officeCode = emp.officeCode
WHERE o.city like '%San Francisco%';

-- вариант 2 - join + subQuery
SELECT c.customerName, 
	CONCAT(emp.firstName, ' ', emp.lastName) as employees_name,
    (SELECT o.city
	FROM classicmodels.offices o
	WHERE o.city like '%San Francisco%') as citySF
FROM classicmodels.customers c
JOIN classicmodels.employees emp on emp.employeeNumber = c.salesRepEmployeeNumber
WHERE emp.officeCode IN (
	 SELECT o.officeCode
	 FROM classicmodels.offices o
	 WHERE o.city like '%San Francisco%'
     );

-- вариант 3 - СТЕ
WITH SF as (
	SELECT o.city, o.officeCode
	FROM classicmodels.offices o
	WHERE o.city like '%San Francisco%')
SELECT c.customerName, 
	CONCAT(emp.firstName, ' ', emp.lastName) as employees_name,
    (SELECT city from SF) as city
    FROM classicmodels.customers c
JOIN classicmodels.employees emp on emp.employeeNumber = c.salesRepEmployeeNumber
WHERE emp.officeCode IN (SELECT officeCode from SF);

-- 8. what is the average number of orders per customer? -- 8. Каково среднее количество заказов на одного клиента?
select * from classicmodels.orders;

select customerNumber, count(orderNumber)
from classicmodels.orders
group by customerNumber
order by customerNumber;

select (count(orderNumber)/count(distinct customerNumber)) avg_orders_per_customers
from classicmodels.orders;

-- 9. what is the average number of days between the order date and ship date? -- 9. Каково среднее количество дней между датой заказа и датой отгрузки?

select sum(DATEDIFF(shippedDate,orderDate))/count(orderNumber) as avg_days 
from classicmodels.orders
where shippedDate is not null;

select AVG(datediff(shippedDate,orderDate)) as avg_days
from classicmodels.orders;

-- 10. sales by year  -- 10. Продажи по годам.

SELECT 
YEAR(paymentDate) years, SUM(amount) sales
FROM classicmodels.payments
GROUP BY years
ORDER BY years;

-- 11. which city has the most number of employees? -- 23. В каком городе больше всего сотрудников?

SELECT o.city, count(emp.employeeNumber) count_emp
FROM classicmodels.employees emp
JOIN classicmodels.offices o on o.officeCode=emp.officeCode
GROUP BY o.city
ORDER BY count_emp desc
limit 1;

-- 12. which office has the biggest sales? -- 24. В каком офисе самые большие продажи?

SELECT 
	o.city,
	sum(p.amount) as total_sales
FROM classicmodels.offices o
JOIN classicmodels.employees emp on o.officeCode=emp.officeCode
JOIN classicmodels.customers c on emp.employeeNumber=c.salesRepEmployeeNumber
JOIN classicmodels.payments p on p.customerNumber=c.customerNumber
GROUP BY o.city
ORDER BY total_sales desc
limit 1;

-- 13. list of employees  by how much they sold in 2003? -- 22. Перечислите сотрудников по объему продаж в 2003 году.

WITH total_sales as (
	SELECT 
		employeeNumber,
		CONCAT(emp.firstName, ' ', emp.lastName) as employeerName,
		YEAR(paymentDate) as years, 
		sum(amount) as sales
	FROM classicmodels.employees emp
	JOIN classicmodels.customers c on c.salesRepEmployeeNumber=emp.employeeNumber
	JOIN classicmodels.payments p on p.customerNumber=c.customerNumber
	group by employeeNumber, years
)
SELECT *
FROM total_sales
WHERE years  = "2003"
ORDER BY sales DESC;

-- 14 join all tables together
-- 2,996
SELECT * -- count(1)
FROM classicmodels.customers c
JOIN classicmodels.employees e ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN classicmodels.offices o ON e.officeCode = o.officeCode
JOIN (select customerNumber, max(paymentDate) as paymentDate, sum(amount) as amount 
from classicmodels.payments group by customerNumber) p ON c.customerNumber = p.customerNumber
JOIN classicmodels.orders orders ON c.customerNumber = orders.customerNumber
JOIN classicmodels.orderdetails det ON orders.orderNumber = det.orderNumber
JOIN classicmodels.products pr ON det.productCode = pr.productCode
JOIN classicmodels.productlines pl ON pr.productLine = pl.productLine;