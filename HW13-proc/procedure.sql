/* 1. Написать функцию возвращающую Клиента с наибольшей суммой покупки. */
USE WideWorldImporters;
GO
CREATE OR ALTER FUNCTION dbo.GetMaxCostomerSumFn ()
RETURNS int
WITH EXECUTE AS CALLER
AS
BEGIN
    RETURN (
    SELECT top 1
	C.CustomerID
    FROM Sales.Customers c
	    OUTER APPLY (
            select	
            c.CustomerId,
            sum(il.ExtendedPrice ) as ExtendedPrice
            FROM Sales.Invoices  as i
            join Sales.InvoiceLines as il 
               on i.InvoiceID = il.InvoiceID and i.CustomerID = c.CustomerId
              group by i.CustomerID
          
          )  as I 
          order by I.ExtendedPrice desc
    )    
END;

SELECT dbo.GetMaxCostomerSumFn() AS CostomerId

/* 2. Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту. */
CREATE OR ALTER PROCEDURE Sales.GetSumByCostomer
(
    @СustomerID int = NULL
)
AS
BEGIN
   select 
		sum(il.ExtendedPrice)
    from Sales.Invoices  as i
        join Sales.InvoiceLines as il 
            on i.InvoiceID = il.InvoiceID and i.CustomerID = @СustomerID
END
GO

EXECUTE Sales.GetSumByCostomer @СustomerID = 2

/* 3. Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему. 
Процедура из задания 2
Хранимая процедура выполняется дольше поскольку для столбца ExtendedPrice происходит сканирование всех значений
*/

USE WideWorldImporters;
GO
CREATE OR ALTER FUNCTION dbo.GetSumByCostomerFn (@СustomerID int)
RETURNS decimal(10, 2)
WITH EXECUTE AS CALLER
AS
BEGIN
    RETURN (
        select	
        sum(il.ExtendedPrice)
        from Sales.Invoices  as i
            join Sales.InvoiceLines as il 
                on i.InvoiceID = il.InvoiceID and i.CustomerID = @СustomerID);
END;
GO


SELECT dbo.GetSumByCostomerFn(2) AS ExtendedPrice

/* 4. Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
*/

USE WideWorldImporters;
GO
CREATE OR ALTER FUNCTION dbo.GetCostomerSumFn ()
RETURNS @rtnTable TABLE (
    CustomerID int,
    ExtendedPrice decimal(10, 2)
)
AS
BEGIN
insert into @rtnTable 
    SELECT 
	C.CustomerID,
    I.ExtendedPrice
    FROM Sales.Customers c
	    OUTER APPLY (
            select	
            c.CustomerId,
            sum(il.ExtendedPrice ) as ExtendedPrice
            FROM Sales.Invoices  as i
            join Sales.InvoiceLines as il 
               on i.InvoiceID = il.InvoiceID and i.CustomerID = c.CustomerId
              group by i.CustomerID
          
          )  as I 
          order by I.ExtendedPrice desc
return
END

select * from dbo.GetCostomerSumFn()

select 
c.CustomerName,
cs.ExtendedPrice
FROM Sales.Customers as c 
    join  dbo.GetCostomerSumFn() as cs
    ON c.CustomerID = cs.CustomerID