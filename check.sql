select * from customers;
select * from transactions;

#1
-- список клиентов с непрерывной историей за год, то есть каждый месяц на регулярной основе без пропусков за указанный годовой период,
-- средний чек за период с 01.06.2015 по 01.06.2016, средняя сумма покупок за месяц, количество всех операций по клиенту за период;информацию в разрезе месяцев:
WITH period AS(
SELECT ID_client, sum_payment,DATE_FORMAT(date_new, '%Y-%m-01') AS month_start
FROM transactions
WHERE date_new >= '2015-06-01' AND date_new<='2016-06-01'),
users AS(
SELECT ID_client 
FROM period 
GROUP BY ID_client
HAVING COUNT(DISTINCT month_start)=12),
month_revenue AS(
SELECT p.ID_client, p.month_start, SUM(p.Sum_payment) AS month_sum, COUNT(*) AS count_operations,
AVG(p.Sum_payment) AS avg_month_check
FROM period p
JOIN users u ON p.ID_client=u.ID_client
GROUP BY p.ID_client,p.month_start)
SELECT ID_client,SUM(month_sum)/12 AS avg_for_month,SUM(month_sum)/SUM(count_operations) AS avg_for_period,SUM(count_operations) AS total_count,
month_start,month_sum,count_operations
FROM month_revenue
GROUP BY ID_client,month_start,month_sum,count_operations
ORDER BY month_start ASC;

#2
-- a)средняя сумма чека в месяц;
-- b)среднее количество операций в месяц;
-- c)среднее количество клиентов, которые совершали операции;
-- d)долю от общего количества операций за год и долю в месяц от общей суммы операций;
-- e)вывести % соотношение M/F/NA в каждом месяце с их долей затрат;

-- a)средняя сумма чека в месяц;
SELECT DATE_FORMAT(date_new,'%Y-%m-01') AS months, AVG(Sum_payment) AS avg_for_month
FROM transactions
WHERE date_new >= '2015-06-01' AND date_new<='2016-06-01'
GROUP BY months
ORDER BY months ASC;

-- b)среднее количество операций в месяц;
SELECT DATE_FORMAT(date_new,'%Y-%m-01') AS months, COUNT(Sum_payment) / 12 AS avg_count_for_month
FROM transactions
GROUP BY months
ORDER BY months ASC;

-- c)среднее количество клиентов, которые совершали операции;
SELECT AVG(clients)
FROM( SELECT COUNT(Id_client) AS clients
FROM transactions 
GROUP BY Id_client) AS s;

-- d)долю от общего количества операций за год и долю в месяц от общей суммы операций;
SELECT DATE_FORMAT(date_new,'%Y-%m-01') AS months, COUNT(*) AS month_count,COUNT(*)/SUM(COUNT(*)) OVER()*100 share_percent,
SUM(Sum_payment) AS month_revenue,
SUM(Sum_payment) / SUM(SUM(Sum_payment)) OVER() * 100 share_revenue
FROM transactions
WHERE date_new >= '2015-06-01' AND date_new<='2016-06-01'
GROUP BY months
ORDER BY months ASC;

-- e)вывести % соотношение M/F/NA в каждом месяце с их долей затрат;



#3
-- возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации, с параметрами сумма и количество операций за весь период, 
-- и поквартально - средние показатели и %.
select * from customers;

SELECT QUARTER(t.date_new) AS quarters,
CASE WHEN AGE IS NULL THEN 'NULL'
WHEN AGE < 18 THEN 'до 18'
WHEN AGE BETWEEN 18 AND 28 THEN '18-28'
WHEN AGE BETWEEN 28 AND 38 THEN '28-38'
WHEN AGE BETWEEN 38 AND 48 THEN '38-48'
WHEN AGE BETWEEN 48 AND 58 THEN '48-58'
WHEN AGE BETWEEN 58 AND 68 THEN '58-68'
WHEN AGE BETWEEN 68 AND 78 THEN '68-78'
WHEN AGE BETWEEN 78 AND 88 THEN '78-88'
ELSE '88+'
END AS age_group,
SUM(Sum_payment) AS total_revenue, COUNT( DISTINCT Id_check) AS count_orders, AVG(Sum_payment) AS avg_payment
FROM customers c
LEFT JOIN transactions t ON c.Id_client = t.ID_client 
GROUP BY quarters,age_group
ORDER BY quarters ASC;
