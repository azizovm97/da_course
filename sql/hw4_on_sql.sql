/*
Азизов Мухаммад
*/

create schema  chinook;	
set search_path to chinook;


/*
1. По каждому сотруднику компании предоставьте следующую информацию: 
id сотрудника, полное имя, позиция (title), id менеджера (reports_to), 
полное имя менеджера и через запятую его позиция
*/

select 
	employee_id
	, concat_ws(' ', first_name, last_name) as full_name
	, title
	, reports_to
	, (select concat_ws(' ', first_name, last_name) from employee where employee_id = e.reports_to) as manager_name
	, (select title from employee where employee_id = e.reports_to) as manager_title
from employee e
;

/*
2. Вытащите список чеков, сумма которых была больше среднего чека за 2023 год. 
Итоговая таблица должна содержать следующие поля: 
invoice_id, invoice_date, monthkey (цифровой код состоящий из года и месяца), 
customer_id, total
*/

select 
	invoice_id
	, invoice_date
	, extract(year from invoice_date) * 100 + extract (month from  invoice_date) as monthkey
	, customer_id
	, total
from invoice
where 
	total > (select avg(total) from invoice where extract(year from invoice_date) > 2023)
;

/*
3. Дополните предыдущую информацию email-ом клиента 
*/

select 
	invoice_id
	, invoice_date
	, extract(year from invoice_date) * 100 + extract (month from  invoice_date) as monthkey
	, customer_id
	, total
	, (select email from customer where customer_id = invoice.customer_id) as email
from invoice
where 
	total > (select avg(total) from invoice where extract(year from invoice_date) > 2023)
;

/*
4. Отфильтруйте результирующий запрос, 
чтобы в нём не было клиентов имеющих почтовый ящик в домене gmail. 
*/

select 
	invoice_id
	, invoice_date
	, extract(year from invoice_date) * 100 + extract (month from  invoice_date) as monthkey
	, customer_id
	, total
	, (select email from customer where customer_id = invoice.customer_id) as email
from invoice
where 
	total > (select avg(total) from invoice where extract(year from invoice_date) > 2023)
	and (select email from customer where customer_id = invoice.customer_id) not like '%@gmail.com'
;

/*
5. Посчитайте какой процент от общей выручки за 2024 год принёс каждый чек. 
*/

select 
	invoice_id
	, invoice_date
	, customer_id
	, total
	, total / (select sum(total) from invoice where extract(year from invoice_date) = 2024) * 100 as procent
from invoice
where extract(year from invoice_date) = 2024
;

/*
6. Посчитайте какой процент от общей выручки за 2024 год принёс каждый клиент компании 
*/

select 
	customer_id
	, sum(total) as customer_total
	, sum(total) / (select sum(total) from invoice where extract(year from invoice_date) = 2024) * 100 as procent
from invoice
where extract(year from invoice_date) = 2024
group by customer_id
;

