/*
Азизов Мухаммад
*/

create schema  chinook;	
set search_path to chinook;


/*
Задача №1
Для каждого клиента посчитайте сумму продаж по годам и месяцам. Итоговая таблица должна содержать следующие поля: customer_id, full_name, monthkey (в числовом формате), total.
Дополните получившуюся таблицу, посчитав для каждого клиента какой процент от общих продаж за каждый месяц он принёс. 
Т.е. если например в феврале 2023-го общая сумма продаж всем клиентам составила 100, а сумма продаж клиенту Х составила 15, тогда процент расчитывается как 15/100.
Дополните таблицу, посчитав для каждого клиента нарастающий итог за каждый год.
Дополните таблицу, добавив для каждого клиента скользящее среднее за 3 последних периода (2 предыдущих периода и текущий период).
Дополните таблицу, посчитав для каждого клиента разницу между суммой текущего периода и суммой предыдущего периода.
*/
with sales_data as (
    select
        c.customer_id,
        c.first_name || ' ' || c.last_name as full_name,
        extract(year from i.invoice_date) as year,
        extract(month from i.invoice_date) as monthkey,
        sum(i.total) as total
    from invoice i
    join customer c on i.customer_id = c.customer_id
    group by c.customer_id, full_name, year, monthkey
),
monthly_totals as (
    select 
        year,
        monthkey,
        sum(total) as month_total
    from sales_data
    group by year, monthkey
),
sales_with_percentage AS (
    select 
        s.customer_id,
        s.full_name,
        s.year,
        s.monthkey,
        s.total,
        m.month_total,
        round(s.total * 100.0 / nullif(m.month_total, 0), 2) as percentage
    from sales_data s
    join monthly_totals m on s.year = m.year and s.monthkey = m.monthkey
),
sales_with_cumulative as (
    select 
        customer_id,
        full_name,
        year,
        monthkey,
        total,
        percentage,
        sum(total) over (partition by customer_id, year order by monthkey) as cumulative_total
    from sales_with_percentage
),
sales_with_moving_average as (
    select 
        customer_id,
        full_name,
        year,
        monthkey,
        total,
        percentage,
        cumulative_total,
        round(avg(total) over (partition by customer_id, year order by monthkey rows between 2 preceding and current row), 2) as moving_avg
    from sales_with_cumulative
)
select 
    customer_id,
    full_name,
    year,
    monthkey,
    total,
    percentage,
    cumulative_total,
    moving_avg,
    total - lag(total) over (partition by customer_id, year order by monthkey) as difference
from sales_with_moving_average
order by customer_id, year, monthkey;


/*
Задача №2
Верните топ 3 продаваемых альбома за каждый год. Итоговая таблица должна содержать следующие поля: год, название альбома, имя исполнителя, количество проданных треков
*/
with album_sales as (
    select 
        a.album_id,
        a.title as album_title,
        ar.name as artist_name,
        extract(year from i.invoice_date) as year,
        SUM(il.quantity) AS total_sold
    from invoice_line il
    join track t on il.track_id = t.track_id
    join album a on t.album_id = a.album_id
    join artist ar on a.artist_id = ar.artist_id
    join invoice i on il.invoice_id = i.invoice_id
    group by a.album_id, album_title, artist_name, year
),
ranked_albums as (
    select 
        year,
        album_title,
        artist_name,
        total_sold,
        rank() over (partition by year order by total_sold desc) as rank
    from album_sales
)
select 
    year,
    album_title,
    artist_name,
    total_sold
from ranked_albums 
where rank <= 3
order by year, rank;

/*
Задача №3
Посчитайте количество клиентов, закреплённых за каждым сотрудником. Итоговая таблица должна содержать следующие поля: id сотрудника, полное имя, количество клиентов
К предыдущему запросу добавьте поле, показывающее какой процент от общей клиентской базы обслуживает каждый сотрудник.
*/

with employee_clients as (
    select 
        e.employee_id,
        e.first_name || ' ' || e.last_name as full_name,
        count(c.customer_id) as client_count
    from employee e
    left join customer c on e.employee_id = c.support_rep_id
    group by e.employee_id, full_name
),
total_clients as (
    select sum(client_count) as total_clients from employee_clients
)
select 
    ec.employee_id,
    ec.full_name,
    ec.client_count,
    round((ec.client_count * 100.0 / tc.total_clients), 2) as percentage
from employee_clients ec, total_clients tc
order by ec.client_count desc;

/*
Задача №4
Для каждого клиента определите дату первой и последней покупки. Посчитайте разницу в годах между первой и последней покупкой.
*/
select 
    c.customer_id,
    c.first_name || ' ' || c.last_name as full_name,
    min(i.invoice_date) as first_purchase,
    max(i.invoice_date) as last_purchase,
    extract(year from max(i.invoice_date)) - extract(year from min(i.invoice_date)) as years_between
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id, full_name
order by years_between desc;
