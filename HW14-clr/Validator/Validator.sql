use WideWorldImporters

-- Чистим от предыдущих экспериментов
DROP FUNCTION IF EXISTS dbo.fn_SayHello
GO
DROP PROCEDURE IF EXISTS dbo.usp_SayHello
GO
DROP ASSEMBLY IF EXISTS SimpleDemoAssembly
GO

-- Включаем CLR
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO

exec sp_configure 'clr enabled', 1;
exec sp_configure 'clr strict security', 0 
GO


reconfigure;
GO

-- Для возможности создания сборок с EXTERNAL_ACCESS или UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 

-- Подключаем dll 
-- Измените путь к файлу!
CREATE ASSEMBLY SimpleDemoAssembly
FROM 'C:\Temp\Validator.dll'
WITH PERMISSION_SET = SAFE;  

-- DROP ASSEMBLY SimpleDemoAssembly



-- Подключить функцию из dll - AS EXTERNAL NAME
CREATE FUNCTION dbo.fn_Replace(@Name nvarchar(100))  
RETURNS nvarchar(100)
AS EXTERNAL NAME [SimpleDemoAssembly].[Validator.Validator].ReplaceFunction;
GO 

-- Используем функцию
SELECT dbo.fn_Replace('+7(495) 555 55 55')

-- Подключить процедуру из dll - AS EXTERNAL NAME 
