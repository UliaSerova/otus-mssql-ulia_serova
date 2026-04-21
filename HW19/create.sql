ALTER DATABASE [Insuranse] ADD FILEGROUP [YearData]
GO

--добавляем файл БД
ALTER DATABASE [Insuranse] ADD FILE 
( NAME = N'Years', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\DATA\InsuranseYeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO
--[Sales].[Invoices]
-- граничные точки
CREATE PARTITION FUNCTION [fnYearPartition](DATE) 
AS 
	RANGE RIGHT FOR VALUES ('20250101','20260101','20270101');
GO

-- расположение секций 
CREATE PARTITION SCHEME [schmYearPartition] 
AS 
	PARTITION [fnYearPartition] ALL TO ([YearData])
GO


--создаем таблицу для секционированния 
SELECT * INTO Insuranse.dbo.PolicyPartitioned
FROM Insuranse.dbo.Policy;

CREATE TABLE Insuranse.dbo.[PolicyLinesYears](
	[PolicyID] [int] NOT NULL,
	[TypeOfPolicy] [int] NOT NULL,
	[CreationDate] [date] NOT NULL, --отличие от оригинала, нужно для секционирования
	[Status] [int] NOT NULL,
	[Agent] [int] NOT NULL,
	[Client] [int] NOT NULL,
	[PolicyData] varchar(MAX) NOT NULL,
	[Premium] decimal(18, 0) NOT NULL,
	[Sum] decimal(18, 0) NOT NULL,
) ON [schmYearPartition]([CreationDate])---в схеме [schmYearPartition] по ключу [InvoiceDate]
GO

ALTER TABLE Insuranse.dbo.PolicyLinesYears 
	ADD CONSTRAINT PK_PolicyLinesYears 
	PRIMARY KEY CLUSTERED  (CreationDate, PolicyID) ON [schmYearPartition]([CreationDate]);


exec master..xp_cmdshell 'bcp "SELECT * from Insuranse.dbo.Policy" queryout "C:\Temp\Policy.txt" -T -w -t "@eu&$" -S yyserova\SQL2022'

DECLARE 
	@path NVARCHAR(256) = N'C:\Temp\',
	@FileName NVARCHAR(256) = N'Policy.txt',
	@onlyScript BIT = 0, 
	@query	NVARCHAR(MAX),
	@dbname NVARCHAR(255) = DB_NAME(),
	@batchsize INT = 1000;
	
BEGIN TRY
	IF @FileName IS NOT NULL
	BEGIN
		SET @query = 'BULK INSERT Insuranse.dbo.PolicyLinesYears
				FROM "' + @path + @FileName + '"
				WITH 
					(
					BATCHSIZE = '+CAST(@batchsize AS VARCHAR(255))+', 
					DATAFILETYPE = ''widechar'',
					FIELDTERMINATOR = ''@eu&$'',
					ROWTERMINATOR =''\n'',
					KEEPNULLS,
					TABLOCK        
					);'

		PRINT @query

		IF @onlyScript = 0
			EXEC sp_executesql @query 
		PRINT 'Bulk insert '+@FileName+' is done, current time '+CONVERT(VARCHAR, GETUTCDATE(),120);
	END;
END TRY

BEGIN CATCH
	SELECT   
		ERROR_NUMBER() AS ErrorNumber  
		,ERROR_MESSAGE() AS ErrorMessage; 

	PRINT 'ERROR in Bulk insert '+@FileName+' , current time '+CONVERT(VARCHAR, GETUTCDATE(),120);

END CATCH
