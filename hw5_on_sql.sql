/*
Азизов Мухаммад
*/

create schema  chinook;	
set search_path to chinook;


/*
ЗАДАНИЕ №1
Посчитайте количество клиентов, закреплённых за каждым сотрудником 
(подсказка: в таблице customer есть поле support_rep_id, которое хранит employee_id сотрудника, за которым закреплён клиент). 
Итоговая таблица должна содержать следующие поля: id сотрудника, полное имя, количество клиентов.
Добавьте к получившейся таблице поле, показывающее какой процент от общей клиентской базы обслуживает каждый сотрудник.
*/
select  
    e.employee_id, 
    e.first_name || ' ' || e.last_name as full_name, 
    count(c.customer_id) as client_count,
    round(100.0 * count(c.customer_id) / (select count(*) from customer), 2) as percentage_clients
from  employee e
left join customer c on e.employee_id = c.support_rep_id
group by e.employee_id, full_name
order by client_count desc;

/*
ЗАДАНИЕ №2
Верните список альбомов, треки из которых вообще не продавались. 
Итоговая таблица должна содержать следующие поля: название альбома, имя исполнителя.
*/
select 
    a.title as album_name, 
    ar.name as artist_name
from album a
left join artist ar on a.artist_id = ar.artist_id
where a.album_id not in (
    select distinct t.album_id
    from track t
    join invoice_line il on t.track_id = il.track_id
);

/*
ЗАДАНИЕ №3
Выведите список сотрудников у которых нет подчинённых.
*/
select 
    e.employee_id, 
    e.first_name || ' ' || e.last_name as full_name
from employee e
where e.employee_id not in 
	(select distinct reports_to 
	from employee 
	where reports_to is not null)
;

/*
ЗАДАНИЕ №4
Верните список треков, которые продавались как в США так и в Канаде. 
Итоговая таблица должна содержать следующие поля: id трека, название трека.
*/

select distinct 
    t.track_id, 
    t.name as track_name
from invoice_line il
join track t on il.track_id = t.track_id
join invoice i on il.invoice_id = i.invoice_id
join customer c on i.customer_id = c.customer_id
where c.country = 'USA'
and t.track_id in (
    select distinct t.track_id
    from invoice_line il
    join track t on il.track_id = t.track_id
    join invoice i on il.invoice_id = i.invoice_id
    join customer c on i.customer_id = c.customer_id
    where c.Country = 'Canada'
);

/*
ЗАДАНИЕ №5
Верните список треков, которые продавались в Канаде, но не продавались в США. 
Итоговая таблица должна содержать следующие поля: id трека, название трека.
*/
select distinct 
    t.track_id, 
    t.name as track_name
from invoice_line il
join track t on il.track_id = t.track_id
join invoice i on il.invoice_id = i.invoice_id
join customer c on i.customer_id = c.customer_id
where c.country = 'Canada'
and t.track_id not in (
    select distinct t.track_id
    from invoice_line il
    join track t on il.track_id = t.track_id
    join invoice i on il.invoice_id = i.invoice_id
    join customer c on i.customer_id = c.customer_id
    where c.Country = 'USA'
);
