/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select [StockItemID], [StockItemName] 
from Warehouse.StockItems where StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select s.SupplierId, s.SupplierName
from Purchasing.Suppliers  as s
LEFT join Purchasing.PurchaseOrders as p on s.SupplierID = p.SupplierID 
where p.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select o.OrderID, 
FORMAT(o.OrderDate, 'dd.MM.yyyy') AS 'ДД.ММ.ГГГГ',
FORMAT(o.OrderDate, 'MMMM') AS 'Название месяца',
DATEPART(quarter, o.OrderDate) AS [Quarter],
(FORMAT(o.OrderDate, 'MM') / 4)+1 AS [Third_of_year],
c.CustomerName 
from Sales.Orders  as o
join Sales.OrderLines as l 
	on o.OrderID = l.OrderID and l.PickingCompletedWhen is not null and (l.UnitPrice < 100 or l.Quantity < 20)
join Sales.Customers as c on o.CustomerID = c.CustomerID
 order by Quarter,Third_of_year, OrderDate

 select o.OrderID, 
FORMAT(o.OrderDate, 'dd.MM.yyyy') AS 'ДД.ММ.ГГГГ',
FORMAT(o.OrderDate, 'MMMM') AS 'Название месяца',
DATEPART(quarter, o.OrderDate) AS [Quarter],
(FORMAT(o.OrderDate, 'MM') / 4)+1 AS [Third_of_year],
c.CustomerName 
from Sales.Orders  as o
join Sales.OrderLines as l 
	on o.OrderID = l.OrderID and l.PickingCompletedWhen is not null and (l.UnitPrice < 100 or l.Quantity < 20)
join Sales.Customers as c on o.CustomerID = c.CustomerID
 order by Quarter,Third_of_year, OrderDate OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select d.DeliveryMethodName,
p.ExpectedDeliveryDate,
s.SupplierName,
pe.FullName
from Purchasing.Suppliers as s
join Purchasing.PurchaseOrders as p 
	on s.SupplierID = p.SupplierID 
	and p.ExpectedDeliveryDate > CAST('2012-12-31' AS DATE) 
	and p.ExpectedDeliveryDate < CAST('2013-01-31' AS DATE)
	and p.IsOrderFinalized = 1
		join Application.DeliveryMethods as d 
			on p.DeliveryMethodID = d.DeliveryMethodID 
			and (d.DeliveryMethodName like 'Air Freight' or d.DeliveryMethodName like 'Refrigerated Air Freight')
		join Application.People as pe
			on pe.PersonID = p.ContactPersonID

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10
	pe.FullName,
	peple.FullName
	from Sales.Orders as o
	JOIN Application.People as pe
	on pe.PersonID = o.SalespersonPersonId 
	JOIN Application.People as peple
	on peple.PersonID = o.CustomerID 
	order by OrderDate DESC

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select DISTINCT pe.PersonID ,pe.FullName, pe.PhoneNumber
from Application.People as pe
	join Sales.Orders as o
	on pe.PersonID = o.CustomerID
	join Sales.OrderLines as l 
	on (o.OrderID = l.OrderID)  
	join Warehouse.StockItems as i 
	on i.StockItemID = i.StockItemID and i.StockItemName like 'Chocolate frogs 250g'
