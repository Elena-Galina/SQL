-- 25 Simple Queries
-- Download MySQL Sample Database: http://www.mysqltutorial.org/mysql-sample-database.aspx

-- 1 show all customers in Australia
select * from classicmodels.customers
where country = 'Australia';

-- 2 show First and Last name of customers in Melbourne
select contactFirstName, contactLastName
from classicmodels.customers
where city = 'Melbourne';

-- 3 show all customers with Credit Limit over $200,000
select * from classicmodels.customers
where creditLimit > 200000;

-- 4 who is the president of the company?
select * from classicmodels.employees
where jobTitle = 'president';

-- 5 how many Sales Reps are in the company?
select count(`salesRepEmployeeNumber`) from classicmodels.customers;

select salesRepEmployeeNumber
from classicmodels.customers
where salesRepEmployeeNumber is not null;

-- 6 show payments in descending order
select * from classicmodels.payments
order by amount desc;

-- 7 what was the check# for the payment done on December 17th 2004 — Какой номер чека был у платежа, произведенного 17 декабря 2004 года?
select checkNumber, paymentDate, amount
from classicmodels.payments
where paymentDate = '2004-12-17';

-- 8 show product line with the word 'realistic' in the description
select * from classicmodels.productlines
where textDescription like '% realistic %';
-- like binary

-- 9 show product name for vendor 'Unimax Art Galleries'
select * from classicmodels.products
where productVendor = 'Unimax Art Galleries';

-- 10 what is the customer number for the highest amount of payment
select customerNumber, amount from classicmodels.payments
order by amount desc
limit 1;

-- 11 which vendor sells 1966 Shelby Cobra?  Какой продавец продает Shelby Cobra 1966 года?
select productVendor, productName from classicmodels.products
where productName like '%1966 Shelby Cobra%';

-- 12 which product is the most and least expensive? Какой товар самый дорогой и самый дешевый?
select productName, buyPrice as least_buyPrice from classicmodels.products
where 
buyPrice = (select min(buyPrice) from classicmodels.products);

select productName, buyPrice as most_buyPrice from classicmodels.products
where 
buyPrice = (select max(buyPrice) from classicmodels.products);

-- 13 which product has the most quantityInStock? Какой товар имеет наибольшее количество на складе?
select productCode, productName, productVendor, quantityInStock from classicmodels.products
order by quantityInStock desc
limit 1;

select max(quantityInStock) as the_most_quantityInStock from classicmodels.products;

-- 14 list all products that have quantity in stock less than 20 -- Перечислите все товары, количество которых на складе меньше 20.
select productCode, productName, productVendor, quantityInStock from classicmodels.products
where quantityInStock < 20;

-- 15 which customer has the highest and lowest credit limit? -- У какого клиента самый высокий и самый низкий кредитный лимит?
select customerNumber, customerName, creditLimit from classicmodels.customers
where creditLimit <> 0
-- order by creditLimit
order by creditLimit desc
limit 1;

-- 16 which vendor sells 1966 Shelby Cobra? --Какой продавец реализует Shelby Cobra 1966 года?
select productName, productVendor from classicmodels.products
where productName like '%Shelby Cobra%' and productName like '%1966%';

-- 17 which product is the most and least expensive? -- Какой товар самый дорогой, а какой самый дешевый?
(select productName, buyPrice, 'min price' as 'price'
from classicmodels.products
order by buyPrice
limit 1)
union all
(select productName, buyPrice, 'max price' as 'price'
from classicmodels.products
order by buyPrice desc
limit 1);

-- 18 which product has the most quantityInStock? -- Какой товар имеет наибольшее количество на складе?
select productName, quantityInStock 
from classicmodels.products
order by quantityInStock desc
limit 1;

-- 19 list all products that have quantity in stock less than 20 -- Перечислите все товары, количество которых на складе меньше 20.
select productName, quantityInStock
from classicmodels.products
where quantityInStock < 20;

-- 20 which customer has the highest and lowest credit limit? -- какого клиента самый высокий и самый низкий кредитный лимит?
(select customerNumber, customerName, creditLimit, 'the lowest credit limit' as 'limit is..'
from classicmodels.customers
where creditLimit > 0
order by creditLimit
limit 1)
union all
(select customerNumber, customerName, creditLimit, 'the highest credit limit' as 'limit is..'
from classicmodels.customers
order by creditLimit desc
limit 1);

-- 21 customers in what city are the most profitable to the company? -- based on highest single payment 
-- Клиенты в каком городе приносят компании наибольшую прибыль? -- на основе наибольшей суммы разового платежа 
select C.city, P.amount 
from classicmodels.payments P, classicmodels.customers C
where P.customerNumber = C.customerNumber
order by P.amount desc
limit 1;

select C.city, sum(P.amount) 
from classicmodels.payments P, classicmodels.customers C
where P.customerNumber = C.customerNumber and C.city = 'Madrid';

-- 22 who is the best customer? --based on single payment -- Кто лучший клиент? -- на основе суммы разового платежа
select C.customerNumber, C.customerName, P.amount
from classicmodels.payments P, classicmodels.customers C
where P.customerNumber = C.customerNumber
order by P.amount desc
limit 1;

-- 23 customers without payment -- Клиенты, не оплатившие покупку
select C.customerNumber, C.customerName, P.amount
from classicmodels.customers C
left join classicmodels.payments P on P.customerNumber = C.customerNumber
where amount is null;

-- 24 list all employees by their (full name: first + last) in alpabetical order -- Перечислите всех сотрудников по алфавиту (полное имя: имя + фамилия)
select CONCAT(E.firstName, ' ', E.lastName) as fullName
from classicmodels.employees E
order by fullName;

-- 25.how many orders are not shipped? -- Сколько заказов не было отгружено?

select count(orderNumber) as count_orders_is_not_shipped
from classicmodels.orders
where shippedDate is null;