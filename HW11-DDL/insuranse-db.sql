USE [Insuranse]
GO
/****** Object:  Table [dbo].[Agent]    Script Date: 05.05.2026 19:11:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Agent](
	[AgentID] [int] NOT NULL,
	[AgentName] [varchar](100) NOT NULL,
	[Address] [varchar](100) NULL,
 CONSTRAINT [PK_Agent] PRIMARY KEY CLUSTERED 
(
	[AgentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Case]    Script Date: 05.05.2026 19:11:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Case](
	[CaseID] [int] NOT NULL,
	[CaseName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Case] PRIMARY KEY CLUSTERED 
(
	[CaseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Client]    Script Date: 05.05.2026 19:11:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Client](
	[ClientID] [int] NOT NULL,
	[ClientName] [varchar](100) NOT NULL,
	[Address] [varchar](100) NULL,
	[Phone] [nchar](20) NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InsuranceCases]    Script Date: 05.05.2026 19:11:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InsuranceCases](
	[InsuranceCaseID] [int] NOT NULL,
	[CaseID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[Description] [varchar](max) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_InsuranceCases] PRIMARY KEY CLUSTERED 
(
	[InsuranceCaseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Policy]    Script Date: 05.05.2026 19:11:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Policy](
	[PolicyID] [int] NOT NULL,
	[TypeOfPolicy] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[Agent] [int] NOT NULL,
	[Client] [int] NOT NULL,
	[PolicyData] [varchar](max) NOT NULL,
	[Premium] [decimal](18, 0) NOT NULL,
	[Sum] [decimal](18, 0) NOT NULL,
	[CreationDate] [date] NULL,
 CONSTRAINT [PK_Policy] PRIMARY KEY CLUSTERED 
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Status]    Script Date: 05.05.2026 19:11:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[StatusID] [int] NOT NULL,
	[StatusName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TypeOfPolicy]    Script Date: 05.05.2026 19:11:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypeOfPolicy](
	[TypeID] [int] NOT NULL,
	[TypeName] [varchar](100) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Case] [int] NOT NULL,
	[PricingPlans] [nchar](100) NULL,
 CONSTRAINT [PK_TypeOfPolicy] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Agent] ([AgentID], [AgentName], [Address]) VALUES (1, N'Иванов Иван Иванович', N'г. Москва, ул. Тверская, д. 15, кв. 23')
INSERT [dbo].[Agent] ([AgentID], [AgentName], [Address]) VALUES (2, N'Петрова Мария Сергеевна', N'г. Санкт-Петербург, Невский пр., д. 45, кв. 12')
INSERT [dbo].[Agent] ([AgentID], [AgentName], [Address]) VALUES (3, N'Сидоров Алексей Петрович', N'г. Казань, ул. Баумана, д. 78, кв. 5')
INSERT [dbo].[Agent] ([AgentID], [AgentName], [Address]) VALUES (4, N'Козлова Елена Владимировна', N'г. Новосибирск, Красный пр., д. 102, кв. 34')
GO
INSERT [dbo].[Case] ([CaseID], [CaseName]) VALUES (1, N'Ущерб третьим лицам при ДТП')
INSERT [dbo].[Case] ([CaseID], [CaseName]) VALUES (2, N'Пожар, затопление, стихийные бедствия, противоправные действия')
INSERT [dbo].[Case] ([CaseID], [CaseName]) VALUES (3, N'Смерть, инвалидность I/II группы, критические заболевания')
INSERT [dbo].[Case] ([CaseID], [CaseName]) VALUES (4, N'Медицинская помощь за границей, отмена поездки, потеря багажа')
INSERT [dbo].[Case] ([CaseID], [CaseName]) VALUES (5, N'Убытки из-за простоя, повреждение оборудования, ответственность перед клиентами')
INSERT [dbo].[Case] ([CaseID], [CaseName]) VALUES (6, N'Травмы при занятиях спортом, на производстве, в быту')
INSERT [dbo].[Case] ([CaseID], [CaseName]) VALUES (7, N'Утрата или повреждение недвижимости, являющейся залогом по ипотеке')
GO
INSERT [dbo].[Client] ([ClientID], [ClientName], [Address], [Phone]) VALUES (1, N'Анна Смирнова', N'г. Екатеринбург, ул. Ленина, д. 25', N'7 912 345-67-89     ')
INSERT [dbo].[Client] ([ClientID], [ClientName], [Address], [Phone]) VALUES (2, N'Дмитрий Волков', N'г. Краснодар, ул. Красная, д. 112', N'7 922 456-78-90     ')
INSERT [dbo].[Client] ([ClientID], [ClientName], [Address], [Phone]) VALUES (3, N'Ольга Иванова', N'г. Ростов-на-Дону, пр. Буденновский, д. 87', N'7 932 567-89-01     ')
INSERT [dbo].[Client] ([ClientID], [ClientName], [Address], [Phone]) VALUES (4, N'Алексей Петров', N'г. Волгоград, ул. Мира, д. 44', N'7 942 678-90-12     ')
GO
INSERT [dbo].[InsuranceCases] ([InsuranceCaseID], [CaseID], [PolicyID], [Description], [Status]) VALUES (1, 1, 1, N'ДТП на пересечении ул. Ленина и пр. Мира. Повреждение переднего бампера и левого крыла.', 1)
INSERT [dbo].[InsuranceCases] ([InsuranceCaseID], [CaseID], [PolicyID], [Description], [Status]) VALUES (2, 2, 2, N'Кража имущества из квартиры на ул. Гагарина, д. 15. Украдены ноутбук и ювелирные изделия.', 2)
INSERT [dbo].[InsuranceCases] ([InsuranceCaseID], [CaseID], [PolicyID], [Description], [Status]) VALUES (3, 3, 3, N'Повреждение кровли дома в результате сильного града. Адрес: г. Екатеринбург, ул. Советская, д. 45.', 3)
INSERT [dbo].[InsuranceCases] ([InsuranceCaseID], [CaseID], [PolicyID], [Description], [Status]) VALUES (4, 4, 4, N'Пожар в коммерческой недвижимости. Повреждено офисное оборудование и мебель.', 4)
INSERT [dbo].[InsuranceCases] ([InsuranceCaseID], [CaseID], [PolicyID], [Description], [Status]) VALUES (5, 5, 5, N'Ущерб от затопления квартиры соседями сверху. Повреждены стены и напольное покрытие.', 1)
GO
INSERT [dbo].[Policy] ([PolicyID], [TypeOfPolicy], [Status], [Agent], [Client], [PolicyData], [Premium], [Sum], [CreationDate]) VALUES (1, 1, 1, 1, 1, N'Страховка на автомобиль Toyota Camry 2022 г.в.', CAST(25000 AS Decimal(18, 0)), CAST(1500000 AS Decimal(18, 0)), CAST(N'2024-01-15' AS Date))
INSERT [dbo].[Policy] ([PolicyID], [TypeOfPolicy], [Status], [Agent], [Client], [PolicyData], [Premium], [Sum], [CreationDate]) VALUES (2, 2, 2, 2, 2, N'Квартира, г. Москва, ул. Ленина, д. 25, кв. 12', CAST(12000 AS Decimal(18, 0)), CAST(5000000 AS Decimal(18, 0)), CAST(N'2024-02-10' AS Date))
INSERT [dbo].[Policy] ([PolicyID], [TypeOfPolicy], [Status], [Agent], [Client], [PolicyData], [Premium], [Sum], [CreationDate]) VALUES (3, 2, 3, 4, 4, N'ДМС для семьи из 3 человек', CAST(35000 AS Decimal(18, 0)), CAST(2000000 AS Decimal(18, 0)), CAST(N'2023-03-20' AS Date))
INSERT [dbo].[Policy] ([PolicyID], [TypeOfPolicy], [Status], [Agent], [Client], [PolicyData], [Premium], [Sum], [CreationDate]) VALUES (4, 4, 1, 3, 4, N'На случай смерти и инвалидности', CAST(8000 AS Decimal(18, 0)), CAST(3000000 AS Decimal(18, 0)), CAST(N'2024-04-05' AS Date))
INSERT [dbo].[Policy] ([PolicyID], [TypeOfPolicy], [Status], [Agent], [Client], [PolicyData], [Premium], [Sum], [CreationDate]) VALUES (5, 3, 4, 4, 3, N'Обязательное страхование автогражданской ответственности', CAST(7500 AS Decimal(18, 0)), CAST(400000 AS Decimal(18, 0)), CAST(N'2024-04-12' AS Date))
GO
INSERT [dbo].[Status] ([StatusID], [StatusName]) VALUES (1, N'Создан')
INSERT [dbo].[Status] ([StatusID], [StatusName]) VALUES (2, N'Действующий')
INSERT [dbo].[Status] ([StatusID], [StatusName]) VALUES (3, N'Аннулирован')
INSERT [dbo].[Status] ([StatusID], [StatusName]) VALUES (4, N'На рассмотрении')
GO
INSERT [dbo].[TypeOfPolicy] ([TypeID], [TypeName], [Description], [Case], [PricingPlans]) VALUES (1, N'Автострахование (КАСКО)', N'Полное страхование автомобиля от ущерба, угона и хищения', 2, N'Базовый: 25 000 руб., Расширенный: 35 000 руб., Премиум: 45 000 руб.                                ')
INSERT [dbo].[TypeOfPolicy] ([TypeID], [TypeName], [Description], [Case], [PricingPlans]) VALUES (2, N'Автострахование (ОСАГО)', N'Обязательное страхование автогражданской ответственности', 1, N'Фиксированная ставка: 7 500 руб./год                                                                ')
INSERT [dbo].[TypeOfPolicy] ([TypeID], [TypeName], [Description], [Case], [PricingPlans]) VALUES (3, N'Страхование недвижимости', N'Защита жилой и коммерческой недвижимости от повреждений и утраты', 3, N'Эконом: 0,1 % от стоимости, Стандарт: 0,2 %, Премиум: 0,3 %                                         ')
INSERT [dbo].[TypeOfPolicy] ([TypeID], [TypeName], [Description], [Case], [PricingPlans]) VALUES (4, N'Медицинское страхование (ДМС)', N'Добровольное медицинское страхование с выбором клиник и услуг', 4, N'Стандарт: 30 000 руб./год, Семейный: 80 000 руб./год, VIP: 150 000 руб./год                         ')
INSERT [dbo].[TypeOfPolicy] ([TypeID], [TypeName], [Description], [Case], [PricingPlans]) VALUES (5, N'Страхование жизни', N'Финансовая защита близких в случае смерти или инвалидности', 5, N'Базовый: 5 000 руб./год (500 000 руб.), Стандартный: 10 000 руб./год (1 000 000 руб.)               ')
INSERT [dbo].[TypeOfPolicy] ([TypeID], [TypeName], [Description], [Case], [PricingPlans]) VALUES (6, N'Страхование имущества', N'Защита домашнего имущества от повреждений и кражи', 6, N'Квартира: 0,15 % от стоимости, Дом: 0,2 % от стоимости                                              ')
INSERT [dbo].[TypeOfPolicy] ([TypeID], [TypeName], [Description], [Case], [PricingPlans]) VALUES (7, N'Туристическое страхование', N'Страхование для путешественников за рубеж и по России', 7, N'Эконом: 50 руб./день, Стандарт: 100 руб./день, Премиум: 200 руб./день                               ')
GO
/****** Object:  FullTextIndex     Script Date: 05.05.2026 19:11:58 ******/
CREATE FULLTEXT INDEX ON [dbo].[Policy](
[PolicyData] LANGUAGE 'Russian')
KEY INDEX [PK_Policy]ON ([PolicyCatalog], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

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
ALTER TABLE [dbo].[InsuranceCases]  WITH CHECK ADD  CONSTRAINT [FK_InsuranceCases_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[Status] ([StatusID])
GO
ALTER TABLE [dbo].[InsuranceCases] CHECK CONSTRAINT [FK_InsuranceCases_Status]
GO
ALTER TABLE [dbo].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_Agent] FOREIGN KEY([Agent])
REFERENCES [dbo].[Agent] ([AgentID])
GO
ALTER TABLE [dbo].[Policy] CHECK CONSTRAINT [FK_Policy_Agent]
GO
ALTER TABLE [dbo].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_Client] FOREIGN KEY([Client])
REFERENCES [dbo].[Client] ([ClientID])
GO
ALTER TABLE [dbo].[Policy] CHECK CONSTRAINT [FK_Policy_Client]
GO
ALTER TABLE [dbo].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[Status] ([StatusID])
GO
ALTER TABLE [dbo].[Policy] CHECK CONSTRAINT [FK_Policy_Status]
GO
ALTER TABLE [dbo].[Policy]  WITH CHECK ADD  CONSTRAINT [FK_Policy_TypeOfPolicy] FOREIGN KEY([TypeOfPolicy])
REFERENCES [dbo].[TypeOfPolicy] ([TypeID])
GO
ALTER TABLE [dbo].[Policy] CHECK CONSTRAINT [FK_Policy_TypeOfPolicy]
GO
ALTER TABLE [dbo].[TypeOfPolicy]  WITH CHECK ADD  CONSTRAINT [FK_TypeOfPolicy_Case] FOREIGN KEY([Case])
REFERENCES [dbo].[Case] ([CaseID])
GO
ALTER TABLE [dbo].[TypeOfPolicy] CHECK CONSTRAINT [FK_TypeOfPolicy_Case]
GO
/****** Object:  StoredProcedure [dbo].[GetFullPolices]    Script Date: 05.05.2026 19:11:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetFullPolices]
AS
BEGIN
   select 
        p.PolicyID,
        (SELECT TypeName FROM dbo.TypeOfPolicy WHERE TypeOfPolicy = TypeID) AS TypeOfPolicyName,
		(SELECT StatusName FROM dbo.Status WHERE p.Status = StatusID) AS StatusName,
		(SELECT AgentName FROM dbo.Agent WHERE p.Agent = AgentID) AS AgentName,
		(SELECT ClientName FROM dbo.Client WHERE p.Client = ClientID) AS ClientName,
        p.Premium,
        p.Sum,
        p.CreationDate
    from dbo.Policy  as p
        
END
GO
