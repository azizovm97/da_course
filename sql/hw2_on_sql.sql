/*
Азизов Мухаммад
*/

/*
Напишите код, который из таблицы invoice вернёт дату самой первой и самой последней покупки.
*/

select 
	min(invoice_date) as first_purchase
	, max(invoice.invoice_date ) as last_purchase 
from invoice
;


/*
Напишите код, который вернёт размер среднего чека для покупок из США
 */

select 
	round(avg(total), 2) as avg_check 
from invoice 
where 
	billing_country = 'USA'
;

/*
Напишите код, который вернёт список городов в которых имеется более одного клиента.
*/

select 
	city 
from customer 
group by 
	city 
having 
	count(customer_id) > 1
;

/*
Из таблицы customer вытащите список телефонных номеров, не содержащих скобок
*/
select 
	phone 
from  customer 
where 
	phone not like '%(%' and phone not like '%)%'
;

/*
Измените текст 'lorem ipsum' так чтобы только первая буква первого слова была в верхнем регистре а всё остальное в нижнем
*/
select  
	initcap('lorem') || ' ' || 'ipsum' as random_text
;


/*
Из таблицы track вытащите список названий песен, которые содежат слово 'run'
*/
select 
	name 
from track 
where 
	name ilike '%run%'
;

/*
Вытащите список клиентов с почтовым ящиком в 'gmail'
*/
select * 
from customer 
where 
	email ilike '%@gmail.com'
;


/*
Из таблицы track найдите произведение с самым длинным названием.
*/
select 
	name 
from track 
order by 
	length(name) desc limit 1
;

/*
Посчитайте общую сумму продаж за 2021 год, в разбивке по месяцам. 
Итоговая таблица должна содержать следующие поля: month_id, sales_sum
*/
select 
	extract(month from invoice_date) as month_id
	, sum(total) as sales_sum 
from invoice 
where 	
	extract(year from invoice_date) = 2021 
group by 
	month_id 
order by 
	month_id
;

/*
К предыдущему запросу (вопрос №6) добавьте также поле с названием месяца 
(для этого функции to_char в качестве второго аргумента нужно передать слово 'month'). 
Итоговая таблица должна содержать следующие поля: month_id, month_name, sales_sum. 
Результат должен быть отсортирован по номеру месяца.
*/
select 
	extract(month from invoice_date) as month_id
	, to_char(invoice_date, 'Month') as month_name
	, sum(total) as sales_sum 
from invoice 
where 
	extract(year from invoice_date) = 2021 
group by 
	month_id
	, month_name 
order by 
	month_id
;

/*
Вытащите список 3 самых возрастных сотрудников компании. 
Итоговая таблица должна содержать следующие поля: full_name (имя и фамилия), 
birth_date, age_now (возраст в годах в числовом формате)
*/
select 
	first_name || ' ' || last_name as full_name
	, birth_date
	, extract(year from age(birth_date)) as age_now 
from employee 
order by 
	age_now desc 
limit 3
;

/*
Посчитайте каков будет средний возраст сотрудников через 3 года и 4 месяца
*/
select 
	avg(extract(year from age(birth_date + interval '3 years 4 months'))) as avg_age_future 
from employee
;

/*
Посчитайте сумму продаж в разбивке по годам и странам. 
Оставьте только те строки где сумма продажи больше 20. 
Результат отсортируйте по году продажи (по возрастанию) и сумме продажи (по убыванию).
*/
select 
	extract(year from invoice_date) as year
	, billing_country
	, sum(total) as sales_sum 
from invoice 
group by 
	year
	, billing_country 
having 
	sum(total) > 20 
order by 
	year asc
	, sales_sum desc
;