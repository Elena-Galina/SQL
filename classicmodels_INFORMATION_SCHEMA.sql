-- использовать указанную БД и в след.запросах не надо указывать ее наименование
use classicmodels; 
-- показать все записи из таблицы customers
select * from customers; 
-- показать все таблицы БД
show tables; 

-- показывает информацию о таблице со всеми ключами и связанными колонками из других таблиц
-- to see primary and foreign keys  (constraints) 
select * from INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
where TABLE_SCHEMA = 'classicmodels'
and TABLE_NAME = 'customers';

select * from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
where TABLE_SCHEMA = 'classicmodels'
and TABLE_Name in ('customers', 'employees');

-- to see all tables in database - все таблицы из БД с полной инфой по каждой таблице
select * from INFORMATION_SCHEMA.tables
where TABLE_SCHEMA = 'classicmodels';
-- and TABLE_NAME = 'orders';

-- to see all columns in database - инфа о всех таблицах БД и их колонках
select * from INFORMATION_SCHEMA.columns
where TABLE_SCHEMA = 'classicmodels';

-- to recreate EER Diagram - инфа для создания EER диаграммы БД самостоятельно
select TABLE_NAME, COLUMN_NAME, 
ordinal_position, COLUMN_TYPE, COLUMN_KEY -- REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
from INFORMATION_SCHEMA.columns
where TABLE_SCHEMA = 'classicmodels'
order by TABLE_NAME, ordinal_position;

-- to see structure of one table (columns, datatypes, keys)
desc classicmodels.customers;

