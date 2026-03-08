CREATE MESSAGE TYPE [//WWI/SB/RequestMessage] VALIDATION=WELL_FORMED_XML;
CREATE MESSAGE TYPE [//WWI/SB/ReplyMessage] VALIDATION=WELL_FORMED_XML;

CREATE CONTRACT [//WWI/SB/Contract] (
	[//WWI/SB/RequestMessage] SENT BY INITIATOR
    , [//WWI/SB/ReplyMessage] SENT BY TARGET
    );

-- цель
CREATE QUEUE TargetQueueWWI;
CREATE SERVICE [//WWI/SB/TargetService] ON QUEUE TargetQueueWWI ([//WWI/SB/Contract]);

--инициатор
CREATE QUEUE InitiatorQueueWWI;
CREATE SERVICE [//WWI/SB/InitiatorService] ON QUEUE InitiatorQueueWWI ([//WWI/SB/Contract]);

CREATE or alter PROCEDURE Sales.SendInvoiceCountByCostomer
@CustomerID INT,
@StartDate date = null,
@EndDate date = null
AS
BEGIN
	SET NOCOUNT ON;

	--Send to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; --!!!
	DECLARE @RequestMessage NVARCHAR(4000);
	DECLARE @Params TABLE (CustomerID INT, StartDate date, EndDate date)
	INSERT INTO @Params VALUES(@CustomerID, @StartDate, @EndDate)
	BEGIN TRAN --!!!

		SELECT @RequestMessage = (SELECT *
									FROM @Params as Params
								  FOR XML AUTO, root('RequestMessage')); 
		
		--Determine the Initiator Service, Target Service and the Contract 
		BEGIN DIALOG @InitDlgHandle --!!!
		FROM SERVICE [//WWI/SB/InitiatorService] TO SERVICE '//WWI/SB/TargetService'
		ON CONTRACT [//WWI/SB/Contract]
		WITH ENCRYPTION = OFF; 

		--Send the Message
		SEND ON CONVERSATION @InitDlgHandle MESSAGE TYPE [//WWI/SB/RequestMessage] (@RequestMessage);
		
		SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END
GO

EXECUTE Sales.SendInvoiceCountByCostomer @CustomerID = 5, @StartDate = '2016-01-01' , @EndDate = '2018-01-01'

CREATE TABLE Sales.InvoiceCountByCostomer
(
    CustomerID INT,
    InvoiceCount INT,
    StartDate date,
    EndDate date
)

CREATE or alter PROCEDURE Sales.GetInvoiceCountByCostomer
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@StartDate date,
			@EndDate date,
			@CustomerID int,
			@xml XML; 
	
	BEGIN TRAN; 

		RECEIVE TOP(1) --!!
			@TargetDlgHandle = Conversation_Handle,
			@Message = Message_Body,
			@MessageType = Message_Type_Name
		FROM dbo.TargetQueueWWI; 

		SET @xml = CAST(@Message AS XML);

		-- InvoiceID
		SELECT @StartDate = R.Iv.value('@StartDate','date') FROM @xml.nodes('/RequestMessage/Params') as R(Iv);
		SELECT @EndDate = R.Iv.value('@EndDate','date') FROM @xml.nodes('/RequestMessage/Params') as R(Iv);
		SELECT @CustomerID = R.Iv.value('@CustomerID','int') FROM @xml.nodes('/RequestMessage/Params') as R(Iv);

		IF EXISTS (SELECT * FROM Sales.Invoices WHERE CustomerID = @CustomerID)BEGIN
		INSERT into  Sales.InvoiceCountByCostomer
		select top 1
			@CustomerID as CustomerID,
			count(i.InvoiceID),
			@StartDate as StartDate,
			@EndDate as EndDate
		from Sales.Invoices  as i
			where i.CustomerID = @CustomerID and i.InvoiceDate >= @StartDate and i.InvoiceDate <= @EndDate
			end;
		
		SELECT @Message AS ReceivedRequestMessage, @MessageType; 
		
		-- Confirm and Send a reply
		IF @MessageType = N'//WWI/SB/RequestMessage' BEGIN
			SET @ReplyMessage = N'<ReplyMessage> Message received</ReplyMessage>'; 
		
			SEND ON CONVERSATION @TargetDlgHandle MESSAGE TYPE [//WWI/SB/ReplyMessage] (@ReplyMessage);
			END CONVERSATION @TargetDlgHandle; --!!!
		END 
		
		SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END

CREATE or alter PROCEDURE Sales.ConfirmInvoice
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1) -- !!
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --!!!
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; 

	COMMIT TRAN; 
END

ALTER QUEUE TargetQueueWWI 
WITH ACTIVATION (
	STATUS = ON -- вкл
	, PROCEDURE_NAME = Sales.GetInvoiceCountByCostomer
	, MAX_QUEUE_READERS = 1 -- 1 worker (0 - хп будет вызвана)
	, EXECUTE AS OWNER -- контекст безопаности
	); 
GO

ALTER QUEUE InitiatorQueueWWI 
WITH ACTIVATION (
	STATUS = ON --  вкл
	, PROCEDURE_NAME = Sales.ConfirmInvoice
	, MAX_QUEUE_READERS = 1 -- 1 worker (0 - хп будет вызвана)
	, EXECUTE AS OWNER -- контекст безопаности
	); 
GO