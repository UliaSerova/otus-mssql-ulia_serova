// Время работы SQL Server:
//  Время ЦП = 528 мс, затраченное время = 392 мс.
// после оптимизации
//Время работы SQL Server:
// Время ЦП = 235 мс, затраченное время = 269 мс.
// самое большое количество чтений было у Invoices - 
// Таблица "Invoices". Сканирований 462, логических операций чтения 162205 
// после Таблица "Invoices". Сканирований 1, логических операций чтения 226
// с добавлением индексов время выполнения снизилось в 2 раза

create index OrderID_Invoices on Sales.Invoices(InvoiceID, OrderID, CustomerID, BillToCustomerID, InvoiceDate)

create NONCLUSTERED index OrderLines 
on Sales.OrderLines (OrderLineID) INCLUDE(OrderID, StockItemID, UnitPrice, Quantity)

create index InvoiceID_CustomerTransactions on Sales.CustomerTransactions(CustomerTransactionID , InvoiceID)

SET STATISTICS io, time on;

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord 
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans 
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans WITH (HOLDLOCK)
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It 
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity) 
        FROM Sales.OrderLines AS Total 
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID