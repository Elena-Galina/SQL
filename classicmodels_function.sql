-- FUNCTIONS 

-- text/string functions
select customerNumber, addressLine1,
ASCII(addressLine1),-- Returns the number code that represents the specific character	
CHAR(addressLine1), -- Returns the ASCII character based on the number code
CONCAT(contactFirstName,' ', contactLastName),-- Concatenates two or more strings together
SUBSTRING(addressLine1,6,1), -- Extracts a substring from a string
LEFT(addressLine1,8), RIGHT(addressLine1,8),-- Extracts a substring from a string (starting from left)	
LTRIM(addressLine1), RTRIM(addressLine1), TRIM(addressLine1), -- Removes leading spaces from a string
LENGTH(addressLine1), -- Returns the length of the specified string
LOWER(contactLastName),UPPER(contactLastName), UCASE(contactLastName)-- Converts a string to upper-case	
from classicmodels.customers;

-- ---------------------------------------------------
-- number functions (with aggregation)
select city, 
AVG(creditLimit),-- Returns the average value of an expression	
COUNT(creditLimit),	-- Returns the count of an expression
MAX(creditLimit),-- Returns the maximum value of an expression	
MIN(creditLimit),-- Returns the minimum value of an expression	
SUM(creditLimit) -- Returns the summed value of an expression
from classicmodels.customers 
group by city
having city ='San Francisco';

-- number functions (without aggregation)
select city, creditLimit,
RAND(creditLimit),	-- Returns a random number or a random number within a range	
FLOOR(creditLimit),	-- Returns the largest integer value that is equal to or less than a number	
ABS(creditLimit),-- Returns the absolute value of a number
CEILING(creditLimit),-- Returns the smallest integer value that is greater than or equal to a number	
ROUND(creditLimit)	-- Returns a number rounded to a certain number of decimal places	
from classicmodels.customers -- select * from classicmodels.customers
where city ='San Francisco';

-- ---------------------------------------------------
-- date functions
select orderNumber,orderDate,shippedDate,
(orderDate)+5,	-- Returns a date after a certain time/date interval has been added		
ADDDATE(orderDate,5),-- Returns a date after a certain time/date interval has been added	
ADDTIME(orderDate,5),-- Returns time after a certain time/date interval has been added	
DATEDIFF(shippedDate,orderDate),	-- Returns the difference between two date values, based on the interval specified		
DAY(orderDate),	-- Returns the day of the month (from 1 to 31) for a given date		
MONTH(orderDate),	-- Returns the month (from 1 to 12) for a given date		
YEAR(orderDate),	-- Returns the year (as a four-digit number) for a given date
NOW()	-- Returns the current date and time			
from classicmodels.orders;	

-- ---------------------------------------------------
-- CASE for data analysts used in segmentation
select 
city, state, country,
case when country = 'USA' then 'USA' else 'non USA' end as US_customer1,
case when length(state)=2 then 'USA' else 'non USA' end as US_customer2
from classicmodels.customers;	

-- ---------------------------------------------------
-- 1 create upper_lower from upper case
drop table if exists mywork.upper_lower;
create table mywork.upper_lower
as 
select UPPER(TRIM(contactFirstName)) as contactFirstName,
UPPER(TRIM(contactLastName)) as contactLastName,
CONCAT(TRIM(contactFirstName),' ', TRIM(contactLastName)) as contactFullName
from classicmodels.customers;
-- select * from mywork.upper_lower;

-- 2 change name from upper to upper_lower case
select contactFirstName, contactLastName,
CONCAT(UCASE(LEFT(contactFirstName, 1))) as first_upper,
SUBSTRING(LCASE(contactFirstName),2,LENGTH(trim(contactFirstName))-1) as second_lower,
CONCAT(CONCAT(UCASE(LEFT(contactFirstName, 1))),SUBSTRING(LCASE(contactFirstName),2,LENGTH(trim(contactLastName))-1)) as ul_case_first,
CONCAT(CONCAT(UCASE(LEFT(contactLastName, 1))),SUBSTRING(LCASE(contactLastName),2,LENGTH(trim(contactLastName))-1)) as ul_case_last,
-- break into two columns
contactFullName,
locate(' ',contactFullName) position_of_space,
left(contactFullName,locate(' ',contactFullName))  as first_name,
substring((contactFullName),locate(' ',contactFullName)+1,length(contactFullName)) last_name
from mywork.upper_lower;

select * from classicmodels.customers;
desc classicmodels.customers;

-- 3 classicmodels.customers. What is the max lenght of each field?
select 
max(length(customerNumber)),
max(length(customerName)),
max(length(contactLastName)),
max(length(contactFirstName)),
max(length(phone)),
max(length(addressLine1)),
max(length(addressLine2)),
max(length(city)),
max(length(state)),
max(length(postalCode)),
max(length(country)),
max(length(salesRepEmployeeNumber)),
max(length(creditLimit))
from classicmodels.customers;