/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT 
	pe.PersonID,
	pe.FullName
FROM Application.People as pe
WHERE  pe.IsSalesPerson = 1 and pe.PersonID NOT IN
    (SELECT SalespersonPersonId
     FROM Sales.Invoices
     WHERE InvoiceDate = CAST('2015-06-04' AS DATE ))

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

select 
	i.StockItemID,
	i.StockItemName,
	(SELECT min(UnitPrice) FROM Sales.InvoiceLines as il where il.StockItemID = i.StockItemID) AS UnitPrice
from Warehouse.StockItems as i 

;with UnitPriceMin_CTE(UnitPrice, StockItemID)
as
(
    select min(UnitPrice), StockItemID FROM Sales.InvoiceLines 
	group by StockItemID
)
select 
	i.StockItemID,
	i.StockItemName,
	UPM.UnitPrice
from UnitPriceMin_CTE AS UPM
	join  Warehouse.StockItems as i 
	on UPM.StockItemID = I.StockItemID

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select top 5
	peple.PersonID,
	peple.FullName, 
	peple.PhoneNumber,
	(SELECT max(t.TransactionAmount) from Sales.CustomerTransactions as t where peple.PersonID = t.CustomerID) AS TransactionAmount
	from Application.People as peple
	order by TransactionAmount DESC

;with TransactionAmountMax_CTE(TransactionAmount, CustomerID)
as
(
    select max(TransactionAmount), CustomerID from Sales.CustomerTransactions
	group by CustomerID
)

select top 5
	peple.PersonID,
	peple.FullName, 
	peple.PhoneNumber,
	TAM.TransactionAmount
from TransactionAmountMax_CTE AS TAM
	join Application.People as peple
	on TAM.CustomerID = peple.PersonID
	order by TAM.TransactionAmount DESC

select top 5 
	peple.PersonID,
	peple.FullName, 
	peple.PhoneNumber,
	max(TransactionAmount) as TransactionAmount
		from Application.People as peple
		join Sales.CustomerTransactions as t
			on peple.PersonID = t.CustomerID
		group by peple.PersonID,  peple.FullName, peple.PhoneNumber
		order by TransactionAmount DESC
/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

;with UnitPriceMax3_CTE(UnitPrice, StockItemID, InvoiceID, TopRank)
as
(
    select max(UnitPrice) as UnitPrice, 
	StockItemID, 
	min(InvoiceID) as InvoiceID, 
	RANK() OVER (ORDER BY max(UnitPrice) DESC) as TopRank
	FROM Sales.InvoiceLines 
	group by StockItemID, UnitPrice
)
select 
	peple.FullName,
	city.CityID,
	city.CityName
from UnitPriceMax3_CTE AS UPM 
	join  Warehouse.StockItems as i 
	on UPM.StockItemID = I.StockItemID and UPM.TopRank < 4
	join Sales.Invoices  as inv
	on inv.InvoiceID = UPM.InvoiceID
	join Application.People as peple
	on inv.PackedByPersonID = peple.PersonID
	join Sales.Customers as customer
	on inv.CustomerID = customer.CustomerID
	join Application.Cities as city
	on customer.DeliveryCityID = city.CityID

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
