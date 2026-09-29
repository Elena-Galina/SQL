-- 1 Data Definition Language (DDL): CREATE TABLE, ALTER TABLE, DROP TABLE	

-- 1.1 CREATE TABLE
-- drop database mywork;
create database mywork;

create table mywork.employee_test(
employee_id int not null,
first_name varchar(75),
last_name varchar(75),
address varchar(100),
sity varchar(30),
state varchar(20),
zip_code varchar(20),
phone varchar(25),
country varchar(50),
hiredate date,
salary decimal(8,2),
PRIMARY KEY (employee_id));

select * from mywork.employee_test; -- пустая таблица, без записей
-- DROP TABLE mywork.employee_test;

-- 1.2 ALTER TABLE

-- ADD COLUMN	 
-- ALTER TABLE table_name	
-- ADD column column_name datatype;

ALTER TABLE mywork.employee_test
ADD column email varchar(50);

-- 1.3 DROP COLUMN
-- ALTER TABLE table_name
-- DROP COLUMN column_name;

ALTER TABLE mywork.employee_test DROP email;

-- 1.4 DROP TABLE
-- DROP TABLE table_name;

DROP TABLE mywork.employee_test;

-- ------------------------------------------
-- 2. Data Query Language (DQL): SELECT		
	-- SELECT column1, column2	
	-- FROM table_name;	
    
    select * from mywork.employee_test;

-- ------------------------------------------	
-- 3. Data Manipulation Language (DML): INSERT, UPDATE, DELETE		

	-- 3.1 INSERT
  -- INSERT INTO table_name (column1, column2, column3, ...)	
  -- VALUES (value1, value2, value3, ...);	

INSERT INTO mywork.employee_test
 (employee_id, hiredate, last_name, first_name, phone, salary)
 VALUES (1, DATE '2025-01-01', 'Ivanov', 'Anton', '415-999-9999', 100000.00);

select * from mywork.employee_test;

-- 3.2 UPDATE table_name
	-- SET column1 = value1, column2 = value2, ...	
	-- WHERE condition;	
	
    UPDATE mywork.employee_test SET salary = (salary * 1.1), phone = '415-999-9999';
    
    UPDATE mywork.employee_test SET first_name = 'Alex';
    
   -- 3.3 DELETE
    -- DELETE FROM table_name
	-- WHERE condition;
	
    DELETE FROM mywork.employee_test WHERE first_name = 'Kathy';

-- if you need to drop the table (DDL Language) 
-- DROP table mywork.employee_test;

-- ------------------------------------------
-- ----------------- IF EXISTS ----------------------

-- Two ways to create a schema/database
-- Error Message if database exists
DROP DATABASE mywork;
CREATE DATABASE mywork;
-- No Error Message 
DROP DATABASE IF EXISTS mywork;
CREATE DATABASE IF NOT EXISTS mywork;

-- drop table
-- Error Message if database exists
DROP TABLE mywork.emp;
-- No Error Message
DROP TABLE IF EXISTS mywork.emp;

-- create table with primary key constraints
CREATE TABLE mywork.emp(
empno int (10) NOT NULL,
ename varchar(10) DEFAULT NULL,
job varchar(10) default null,
mrg int (10) default null,
hiredate date,
sal numeric (7,2),
comm numeric (7,2) null,
dept int (10),
PRIMARY KEY (empno));

-- to see the structure of the table 
desc mywork.emp;

-- to see all records in the table
select * from mywork.emp;

-- insert records in the table ('' for varchar colomns)
insert into mywork.emp (empno,ename,job,mrg,hiredate,sal,comm,dept)
values
    (1,'JOHNSON','ADMIN',6,'1990-12-17',18000,NULL,4),
    (2,'HARDING','MANAGER',9,'1990-12-17',52000,300,3),
	(3,'TAFT','SALES I',2,'1995-12-17',25000,500,3),
    (4,'HOOVER','SALES I',2,'1990-04-02',27000,NULL,3),
    (5,'LINCOLN','TECH',6,'1994-06-23',22500,1400,4),
    (6,'GARFIELD','MANAGER',9,'1993-05-01',54000,NULL,4),
    (7,'POLK','TECH',6,'1997-09-22',25000,NULL,4),
    (8,'GRANT','ENGINEER',10,'1997-03-30',32000,NULL,2),
    (9,'JACKSON','CEO',NULL,'1990-01-01',75000,NULL,4),
    (10,'FILLMORE','MANAGER',9,'1994-08-09',56000,NULL,2),
    (11,'ADAMS','ENGINEER',10,'1996-03-15',34000,NULL,2),
    (12,'WASHINGTON','ADMIN',6,'1998-04-16',18000,NULL,4),
    (13,'MONROE','ENGINEER',10,'2000-12-03',30000,NULL,2),
    (14,'ROOSEVELT','CPA',9,'1995-10-12',35000,NULL,1);

select * from mywork.emp;

-- rename column       -- alter table ... rename column... to
alter table mywork.emp rename column job to job_title;
alter table mywork.emp rename column mrg to mgr;

-- update records      -- update ... set... where
update mywork.emp set ename = 'SMITH' where ename = 'POLK';
update mywork.emp set ename = 'CAT_GARF' where ename = 'GARFIELD';

-- delete records     -- delete from .... where
delete from mywork.emp where ename = 'ROOSEVELT';
delete from mywork.emp where ename = 'CAT_GARF';

-- add column        -- alter table ... add column ... 
alter table mywork.emp add column bonus_percent int (3);
alter table mywork.emp add column phone varchar(25);

-- update records     -- update ... SET ...
UPDATE mywork.emp SET phone = '415-999-9999';
UPDATE mywork.emp SET phone = '415-000-0000' where ename = 'GRANT';

-- drop column
alter table mywork.emp drop column bonus_percent;

DROP TABLE IF EXISTS mywork.dept;
-- CREATE TABLE mywork.dept;
CREATE TABLE IF NOT EXISTS mywork.dept (
deptno INT NOT NULL,
dname VARCHAR(14),
loc VARCHAR(13),
 PRIMARY KEY (deptno));
 
 select * from mywork.dept;
 select * from mywork.emp;
 
 -- ALTER TABLE mywork.emp drop foreign key fk_dept;  -- перед созданием foreign key - сначала надо добавить записи в таблицу
  
 insert into mywork.dept values (1,'ACCOUNTING','ST LOUIS');
 insert into mywork.dept values (2,'RESEARCH','NEW YORK');
 insert into mywork.dept values (3,'SALES','ATLANTA');
 insert into mywork.dept values (4,'OPERATIONS','SEATTLE');
 
  -- to create foreign key
ALTER TABLE mywork.emp
ADD FOREIGN KEY fk_dept(dept)
REFERENCES dept(deptno)
ON DELETE NO ACTION
ON UPDATE CASCADE;
 
desc mywork.emp;
desc mywork.dept;

 select * from mywork.dept;
 select * from mywork.emp;

-- ______________________________________________________
/* DELETE & TRUNCATE
*/
-- Создаем таблицу

drop table if exists mywork.users_test;
create table mywork.users_test (
user_id int auto_increment primary key,
user_name varchar(50)
);

-- Вносим данные в таблицу
insert into mywork.users_test (user_name)
values ('Elena'), ('Alsu'), ('Ruslan'), ('Ivan');

-- Проверяем, ID должен быть - 1, 2, 3, 4
select * from mywork.users_test;

-- ----------- DELETE --------------

-- Удаляем все записи с помощью DELETE
delete from mywork.users_test;

-- Добавляем новую запись, в ней ID будет продолжаться далее
insert into mywork.users_test (user_name)
values ('Marina');

-- Проверяем созданную запись, ID будет = 5
select * from mywork.users_test;

-- ----------- TRUNCATE --------------

-- Очищаем таблицу с помощью TRUNCATE "под ноль"
truncate table mywork.users_test;

-- Добавляем новую запись, в ней ID будет продолжаться далее
insert into mywork.users_test (user_name)
values ('Alexander');

-- Проверяем созданную запись, ID у Alexander будет = 1,
-- т.е. начнется сначала после truncate table
select * from mywork.users_test;

-- Таким образом, TRUNCATE полностью пересоздал таблицу и сбросил счетчик auto_increment до 0