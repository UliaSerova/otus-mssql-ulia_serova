/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

;with InvoiceByM_CTE(InvoiceID, InvoiceDate, InvoiceDateLast, Customer, ExtendedPrice)
as
(
    select 
		i.InvoiceID,
		i.InvoiceDate,
		EOMONTH(i.InvoiceDate),
		pe.FullName,
        il.ExtendedPrice as ExtendedPrice
    from Sales.Invoices  as i
        join Sales.InvoiceLines as il 
            on i.InvoiceID = il.InvoiceID and i.InvoiceDate > CAST('2014-12-31' AS DATE )
        join Application.People as pe 
            on pe.PersonID = i.CustomerID
    group by  pe.FullName, i.InvoiceID, i.InvoiceDate, il.ExtendedPrice
)

select 
	i.InvoiceID,
	i.InvoiceDate,
	i.Customer,
	i.ExtendedPrice,
	(select coalesce(sum(ic.ExtendedPrice), 0) from InvoiceByM_CTE as ic where i.InvoiceDateLast >= ic.InvoiceDateLast) as Price
		from InvoiceByM_CTE as i
		group by  i.InvoiceID,  i.Customer, i.ExtendedPrice, i.InvoiceDate, i.InvoiceDateLast, i.ExtendedPrice
		order by i.InvoiceDate

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
данный запрос выдает 0% стоимости запроса по отношению к предыдущему

select 
	i.InvoiceID,
	i.InvoiceDate,
	pe.FullName,
    sum(il.ExtendedPrice) as Price,
    sum(il.ExtendedPrice) OVER (ORDER BY EOMONTH(i.InvoiceDate) RANGE UNBOUNDED PRECEDING) as ExtendedPrice
    from Sales.Invoices  as i
        join Sales.InvoiceLines as il 
            on i.InvoiceID = il.InvoiceID and i.InvoiceDate > CAST('2014-12-31' AS DATE )
        join Application.People as pe 
            on pe.PersonID = i.CustomerID
    group by  i.InvoiceID, pe.FullName,  i.InvoiceDate, il.ExtendedPrice
    order by i.InvoiceDate

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

;with StockItem_CTE(StockItemName, InvoiceDate, Quantity)
as
(
    select 
	si.StockItemName as 'StockItemName',
	EOMONTH(i.InvoiceDate) as 'InvoiceDate',
	sum(il.Quantity) OVER (PARTITION BY EOMONTH(i.InvoiceDate), si.StockItemName) as Quantity
from Sales.Invoices  as i
	join Sales.InvoiceLines as il 
	on i.InvoiceID = il.InvoiceID and i.InvoiceDate > CAST('2015-12-31' AS DATE ) 
	join Warehouse.StockItems as si 
	on il.StockItemID = si.StockItemID
group by si.StockItemName, i.InvoiceDate, il.Quantity
)

select 
StockItemName, 
FORMAT(InvoiceDate, 'MM.yyyy') as 'MM.yyyy',
Quantity
from (
	select StockItemName, 
	InvoiceDate,
	Quantity,
	dense_rank() OVER (PARTITION BY sicte.InvoiceDate ORDER BY Quantity DESC) as TopRank
	from StockItem_CTE as sicte) as sicte where sicte.TopRank < 3
group by sicte.TopRank ,sicte.StockItemName, sicte.InvoiceDate, sicte.Quantity
order by  sicte.InvoiceDate, sicte.TopRank

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select 
	StockItemID,
	StockItemName,
	Brand,
	RecommendedRetailPrice,
	TypicalWeightPerUnit,
	ROW_NUMBER() OVER (PARTITION BY LEFT(REPLACE(StockItemName, '"', ''), 1) ORDER BY StockItemName) AS StockItemNameNumber,
	sum(QuantityPerOuter) OVER () as Quantity,
	sum(QuantityPerOuter) OVER (PARTITION BY LEFT(REPLACE(StockItemName, '"', ''), 1)) AS SumNumber,
	LEAD(StockItemID) OVER (order BY LEFT(REPLACE(StockItemName, '"', ''), 1)) AS NextStockItemID,
	LAG(StockItemID) OVER (order BY LEFT(REPLACE(StockItemName, '"', ''), 1)) AS PreviousStockItemID,
	LAG(StockItemName, 2, 'No items') OVER (order BY LEFT(REPLACE(StockItemName, '"', ''), 1)) AS PreviousStockItemName,
	ntile(30) over (ORDER BY sum(TypicalWeightPerUnit) desc) AS GroupsByWeight
from Warehouse.StockItems as si 
group by StockItemID, StockItemName, Brand, RecommendedRetailPrice, TypicalWeightPerUnit, QuantityPerOuter
order by StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

;with InvoicePerson_CTE(InvoiceDate, SalespersonPersonId, SalespersonFullName, CustomerID, CustomerName,  ExtendedPrice, TopRank) 
as (
select 
		i.InvoiceDate,
		i.SalespersonPersonID,
		pe.FullName,
		i.CustomerID,
		customer.CustomerName,
		sum(il.ExtendedPrice),
		dense_rank() OVER (PARTITION BY i.SalespersonPersonID  ORDER BY InvoiceDate DESC) as TopRank
    from Sales.Invoices  as i
        join Sales.InvoiceLines as il 
            on i.InvoiceID = il.InvoiceID
		join Application.People as pe
			on  pe.PersonID = i.SalespersonPersonID
		join Sales.Customers as customer
			on i.CustomerID = customer.CustomerID
    group by  i.InvoiceDate, i.SalespersonPersonID, i.CustomerID, pe.FullName, customer.CustomerName
)
SELECT  
	SalespersonPersonId, 
	SalespersonFullName,
	CustomerID,
	CustomerName,
	InvoiceDate,
	ExtendedPrice
	from InvoicePerson_CTE where TopRank = 1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;with CustomerStockItems_CTE(InvoiceDate,  CustomerID, CustomerName,  UnitPrice, StockItemID, TopRank) 
as (
select 
		max(i.InvoiceDate),
		i.CustomerID,
		customer.CustomerName,
		il.UnitPrice,
		il.StockItemID,
		dense_rank() OVER (PARTITION BY i.CustomerID  ORDER BY il.UnitPrice DESC) as TopRank
    from Sales.Invoices  as i
        join Sales.InvoiceLines as il 
            on i.InvoiceID = il.InvoiceID
		join Sales.Customers as customer
			on i.CustomerID = customer.CustomerID
    group by  i.CustomerID, customer.CustomerName, il.UnitPrice, il.StockItemID
)
SELECT  
	CustomerID,
	CustomerName,
	InvoiceDate,
	UnitPrice,
	StockItemID
	from CustomerStockItems_CTE where TopRank < 3
	order by CustomerID

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 