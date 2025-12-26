/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select 
FORMAT(DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1), 'dd.MM.yyyy') as InvoiceDateStr,
ISNULL([Tailspin Toys (Sylvanite, MT)], 0) AS "Sylvanite, MT", 
ISNULL([Tailspin Toys (Peeples Valley, AZ)], 0) AS "Peeples Valley, AZ", 
ISNULL([Tailspin Toys (Medicine Lodge, KS)], 0) AS "Medicine Lodge, KS", 
ISNULL([Tailspin Toys (Gasport, NY)], 0) AS "Gasport, NY", 
ISNULL([Tailspin Toys (Jessie, ND)], 0) AS "Jessie, ND"
from 
(SELECT 
	C.CustomerName, 
	Quantity,
	EOMONTH(InvoiceDate) as InvoiceDate
FROM Sales.Customers C
	OUTER APPLY (
			SELECT 
				sum(il.Quantity) OVER (PARTITION BY EOMONTH(i.InvoiceDate), i.CustomerID) as Quantity,
				min(i.InvoiceDate) OVER (PARTITION BY EOMONTH(i.InvoiceDate), i.CustomerID) as InvoiceDate
				from Sales.Invoices I
				join Sales.InvoiceLines as il 
						on i.InvoiceID = il.InvoiceID and C.CustomerID = i.CustomerID
				group by i.CustomerID, i.InvoiceDate, il.Quantity		

	) as I where CustomerID > 1 and CustomerID < 7
)t
 PIVOT(
	SUM(Quantity) 
	FOR CustomerName IN (
	[Tailspin Toys (Sylvanite, MT)],
	[Tailspin Toys (Peeples Valley, AZ)],
	[Tailspin Toys (Medicine Lodge, KS)],
	[Tailspin Toys (Gasport, NY)],
	[Tailspin Toys (Jessie, ND)]
	)
) AS pvt
order by InvoiceDate

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT 
CustomerName,
AddressLine
FROM (
	SELECT 
	 CustomerName, 
	 DeliveryAddressLine1, 
	 DeliveryAddressLine2, 
	 PostalAddressLine1, 
	 PostalAddressLine2
	FROM Sales.Customers where CustomerName like '%Tailspin Toys%'
) AS Customer
UNPIVOT ( 
	AddressLine 
	FOR Name IN (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2) 
) AS unpt

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT 
CountryID,
CountryName,
Code
FROM (
	SELECT 
	 CountryID, 
	 CountryName, 
	 CAST(IsoAlpha3Code AS varchar(5)) as IsoAlpha3Code,
	 CAST(IsoNumericCode AS varchar(5)) as IsoNumericCode
	FROM Application.Countries
) AS Customer
UNPIVOT ( 
	Code 
	FOR Name IN ( IsoAlpha3Code, IsoNumericCode) 
) AS unpt
 

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT 
	C.CustomerID, 
	C.CustomerName, 
	I.StockItemID,
	UnitPrice,
	InvoiceDate
FROM Sales.Customers C
	OUTER APPLY (
			SELECT 
				UnitPrice,
				il.StockItemID,
				max(i.InvoiceDate) as InvoiceDate,
				dense_rank() OVER (ORDER BY il.UnitPrice DESC) as TopRank
					from Sales.Invoices I
					join Sales.InvoiceLines as il 
						on i.InvoiceID = il.InvoiceID and C.CustomerID = i.CustomerID
						group by StockItemID, i.CustomerID, UnitPrice

	) as I where TopRank < 3
group by C.CustomerID, C.CustomerName, StockItemID, UnitPrice, InvoiceDate
order by C.CustomerID, UnitPrice

		

