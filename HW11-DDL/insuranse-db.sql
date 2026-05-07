CREATE DATABASE Insuranse
GO
USE [Insuranse]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Agent](
	[AgentID] INT IDENTITY(1, 1) PRIMARY KEY,
	[AgentName] [nvarchar](100) NOT NULL,
	[Address] [nvarchar](100) NULL)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Case](
	[CaseID] INT IDENTITY(1, 1) PRIMARY KEY,
	[CaseName] [nvarchar](100) NOT NULL)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Client](
	[ClientID] INT IDENTITY(1, 1) PRIMARY KEY,
	[ClientName] [nvarchar](100) NOT NULL,
	[Address] [nvarchar](100) NULL,
	[Phone] [nvarchar](20) NULL)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InsuranceCases](
	[InsuranceCaseID] INT IDENTITY(1, 1) PRIMARY KEY,
	[CaseID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[StatusID] [int] NOT NULL,
	[CreationDate] [date] NULL,
	[Sum] [decimal](18, 2))
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Policy](
	[PolicyID] int IDENTITY(1, 1),
	[TypeOfPolicy] [int] NOT NULL,
	[StatusID] [int] NOT NULL,
	[AgentID] [int] NOT NULL,
	[ClientID] [int] NOT NULL,
	[PolicyData] [nvarchar](max) NOT NULL,
	[Premium] [decimal](18, 2) NOT NULL,
	[Sum] [decimal](18, 2) NOT NULL,
	[CreationDate] [date] NULL,
    CONSTRAINT [PK_Policy]  PRIMARY KEY CLUSTERED (
        [PolicyID] ASC
    ))
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[StatusID] INT IDENTITY(1, 1) PRIMARY KEY,
	[StatusName] [nvarchar](100) NOT NULL)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypeOfPolicy](
	[TypeID] INT IDENTITY(1, 1) PRIMARY KEY,
	[TypeName] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[CaseID] [int] NOT NULL,
	[PricingPlans] [nchar](100) NULL)
 
GO

INSERT [dbo].[Agent] ([AgentName], [Address]) 
	VALUES ( N'Иванов Иван Иванович', N'г. Москва, ул. Тверская, д. 15, кв. 23'),
		   ( N'Петрова Мария Сергеевна', N'г. Санкт-Петербург, Невский пр., д. 45, кв. 12'),
		   ( N'Сидоров Алексей Петрович', N'г. Казань, ул. Баумана, д. 78, кв. 5'),
		   ( N'Козлова Елена Владимировна', N'г. Новосибирск, Красный пр., д. 102, кв. 34')
GO

INSERT [dbo].[Case] ([CaseName]) 
	VALUES ( N'Ущерб третьим лицам при ДТП'),
	(N'Пожар, затопление, стихийные бедствия, противоправные действия'),
	(N'Смерть, инвалидность I/II группы, критические заболевания'),
	(N'Медицинская помощь за границей, отмена поездки, потеря багажа'),
	(N'Убытки из-за простоя, повреждение оборудования, ответственность перед клиентами'),
	(N'Травмы при занятиях спортом, на производстве, в быту'),
	(N'Утрата или повреждение недвижимости, являющейся залогом по ипотеке')
GO

INSERT [dbo].[Client] ([ClientName], [Address], [Phone]) 
	VALUES (N'Анна Смирнова', N'г. Екатеринбург, ул. Ленина, д. 25', N'7 912 345-67-89'),
	( N'Дмитрий Волков', N'г. Краснодар, ул. Красная, д. 112', N'7 922 456-78-90 '),
	(N'Ольга Иванова', N'г. Ростов-на-Дону, пр. Буденновский, д. 87', N'7 932 567-89-01'),
	(N'Алексей Петров', N'г. Волгоград, ул. Мира, д. 44', N'7 942 678-90-12')
GO

INSERT [dbo].[InsuranceCases] ( [CaseID], [PolicyID], [Description], [StatusID], [CreationDate], [Sum]) 
	VALUES ( 1, 1, N'ДТП на пересечении ул. Ленина и пр. Мира. Повреждение переднего бампера и левого крыла.', 1, CAST(N'2025-01-15' AS Date), null),
	( 2, 2, N'Кража имущества из квартиры на ул. Гагарина, д. 15. Украдены ноутбук и ювелирные изделия.', 2, CAST(N'2024-01-01' AS Date), 1000),
	( 3, 3, N'Повреждение кровли дома в результате сильного града. Адрес: г. Екатеринбург, ул. Советская, д. 45.', 3, CAST(N'2026-01-01' AS Date), 2000),
	( 4, 4, N'Пожар в коммерческой недвижимости. Повреждено офисное оборудование и мебель.', 4, CAST(N'2025-11-01' AS Date), null),
	( 5, 5, N'Ущерб от затопления квартиры соседями сверху. Повреждены стены и напольное покрытие.', 1, CAST(N'2026-01-02' AS Date), null)
GO

INSERT [dbo].[Policy] ( [TypeOfPolicy], [StatusID], [AgentID], [ClientID], [PolicyData], [Premium], [Sum], [CreationDate]) 
	VALUES ( 1, 1, 1, 1, N'{"VIN": "5YFBURHE0LP051234","Make": "Honda","Model": "Civic","Year": 2019}', CAST(25000 AS Decimal(18, 0)), CAST(1500000 AS Decimal(18, 0)), CAST(N'2024-01-15' AS Date)),
	( 2, 2, 2, 2, N'{"Make": "Honda","Model": "Civic","Year": 2019}', CAST(12000.08 AS Decimal(18, 0)), CAST(5000000 AS Decimal(18, 0)), CAST(N'2024-02-10' AS Date)),
	( 2, 3, 4, 4, N'{"VIN": "5YFBURHE0LP051234","Make": "Honda","Model": "Civic","Year": 2020}', CAST(35000 AS Decimal(18, 0)), CAST(2000000 AS Decimal(18, 0)), CAST(N'2023-03-20' AS Date)),
	( 4, 1, 3, 4, N'{"VIN": "5YFBURHE0LP051234","Make": "Honda","Model": "Civic","Year": 2022}', CAST(8000 AS Decimal(18, 0)), CAST(3000000 AS Decimal(18, 0)), CAST(N'2024-04-05' AS Date)),
	( 3, 4, 4, 3, N'{"VIN": "5YFBURHE0LP051234","Make": "Honda","Model": "Civic","Year": 2024}', CAST(7500 AS Decimal(18, 0)), CAST(400000 AS Decimal(18, 0)), CAST(N'2024-04-12' AS Date))
GO

INSERT [dbo].[Status] ([StatusName]) 
VALUES ( N'Создан'), (N'Действующий'), (N'Аннулирован'), (N'На рассмотрении')
GO

INSERT [dbo].[TypeOfPolicy] ([TypeName], [Description], [CaseID], [PricingPlans]) 
	VALUES ( N'Автострахование (КАСКО)', N'Полное страхование автомобиля от ущерба, угона и хищения', 2, N'Базовый: 25 000 руб., Расширенный: 35 000 руб., Премиум: 45 000 руб.'),
	( N'Автострахование (ОСАГО)', N'Обязательное страхование автогражданской ответственности', 1, N'Фиксированная ставка: 7 500 руб./год '),
	( N'Страхование недвижимости', N'Защита жилой и коммерческой недвижимости от повреждений и утраты', 3, N'Эконом: 0,1 % от стоимости, Стандарт: 0,2 %, Премиум: 0,3 % '),
	( N'Медицинское страхование (ДМС)', N'Добровольное медицинское страхование с выбором клиник и услуг', 4, N'Стандарт: 30 000 руб./год, Семейный: 80 000 руб./год, VIP: 150 000 руб./год '),
	( N'Страхование жизни', N'Финансовая защита близких в случае смерти или инвалидности', 5, N'Базовый: 5 000 руб./год (500 000 руб.), Стандартный: 10 000 руб./год (1 000 000 руб.)'),
	( N'Страхование имущества', N'Защита домашнего имущества от повреждений и кражи', 6, N'Квартира: 0,15 % от стоимости, Дом: 0,2 % от стоимости'),
	( N'Туристическое страхование', N'Страхование для путешественников за рубеж и по России', 7, N'Эконом: 50 руб./день, Стандарт: 100 руб./день, Премиум: 200 руб./день ')
GO


CREATE FULLTEXT CATALOG PolicyCatalog
     WITH ACCENT_SENSITIVITY = ON
     AS DEFAULT
     AUTHORIZATION dbo
   GO   

-- для поиска по объекту полиса
CREATE FULLTEXT INDEX 
ON [dbo].[Policy](PolicyData)
key Index PK_Policy

GO
ALTER TABLE [dbo].[InsuranceCases]  WITH CHECK ADD  CONSTRAINT [FK_InsuranceCases_CaseID] FOREIGN KEY([CaseID])
REFERENCES [dbo].[Case] ([CaseID])
GO
ALTER TABLE [dbo].[InsuranceCases] CHECK CONSTRAINT [FK_InsuranceCases_CaseID]
GO
ALTER TABLE [dbo].[InsuranceCases]  WITH CHECK ADD  CONSTRAINT [FK_InsuranceCases_PolicyID] FOREIGN KEY([PolicyID])
REFERENCES [dbo].[Policy] ([PolicyID])
GO
ALTER TABLE [dbo].[InsuranceCases] CHECK CONSTRAINT [FK_InsuranceCases_PolicyID]
GO
ALTER TABLE [dbo].[InsuranceCases]  WITH CHECK ADD  CONSTRAINT [FK_InsuranceCases_Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[Status] ([StatusID])
GO
ALTER TABLE [dbo].[InsuranceCases] CHECK CONSTRAINT [FK_InsuranceCases_Status]
GO
ALTER TABLE [dbo].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_Agent] FOREIGN KEY([AgentID])
REFERENCES [dbo].[Agent] ([AgentID])
GO
ALTER TABLE [dbo].[Policy] CHECK CONSTRAINT [FK_Policy_Agent]
GO
ALTER TABLE [dbo].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_Client] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Client] ([ClientID])
GO
ALTER TABLE [dbo].[Policy] CHECK CONSTRAINT [FK_Policy_Client]
GO
ALTER TABLE [dbo].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[Status] ([StatusID])
GO
ALTER TABLE [dbo].[Policy] CHECK CONSTRAINT [FK_Policy_Status]
GO
ALTER TABLE [dbo].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_TypeOfPolicy] FOREIGN KEY([TypeOfPolicy])
REFERENCES [dbo].[TypeOfPolicy] ([TypeID])
GO
ALTER TABLE [dbo].[Policy] CHECK CONSTRAINT [FK_Policy_TypeOfPolicy]
GO
ALTER TABLE [dbo].[TypeOfPolicy]  WITH CHECK ADD  CONSTRAINT [FK_TypeOfPolicy_Case] FOREIGN KEY([CaseID])
REFERENCES [dbo].[Case] ([CaseID])
GO
ALTER TABLE [dbo].[TypeOfPolicy] CHECK CONSTRAINT [FK_TypeOfPolicy_Case]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[GetFullPolices]
AS
BEGIN
   select 
        p.PolicyID,
        tp.TypeName AS TypeOfPolicyName,
		s.StatusName AS StatusName,
		a.AgentName  AS AgentName,
		c.ClientName AS ClientName,
        p.Premium,
        p.Sum,
        p.CreationDate
    from dbo.Policy as p
	join dbo.TypeOfPolicy as tp
		on p.TypeOfPolicy = tp.TypeID
	join dbo.Status as s
		on p.StatusID = s.StatusID
    join dbo.Agent as a
		on p.AgentID = a.AgentID  
	join dbo.Client as c
		on p.ClientID = c.ClientID
END
GO
