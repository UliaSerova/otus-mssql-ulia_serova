SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

-- Сайт страховой фирмы
-- Сотрудник оформляющий полис
CREATE TABLE [Agent] (
    [AgentID] int  NOT NULL ,
    [AgentName] varchar(100) collate Cyrillic_General_CS_AI NOT NULL ,
    [Address] varchar(100) collate Cyrillic_General_CS_AI  NULL ,
    CONSTRAINT [PK_Agent] PRIMARY KEY CLUSTERED (
        [AgentID] ASC
    )
)

-- Страхователь
CREATE TABLE [Client] (
    [ClientID] int  NOT NULL ,
    [ClientName] varchar(100) collate Cyrillic_General_CS_AI NOT NULL ,
    [Address] varchar(100) collate Cyrillic_General_CS_AI,
    [Phone] varchar  NULL ,
    CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED (
        [ClientID] ASC
    )
)

-- Тип полиса, например страхование авто
CREATE TABLE [TypeOfPolicy] (
    [TypeID] int  NOT NULL ,
    [TypeName] varchar(100) collate Cyrillic_General_CS_AI  NOT NULL ,
    [Description] varchar(1000) collate Cyrillic_General_CS_AI  NULL ,
    [Case] int  NOT NULL ,
    -- Тарифы по разным критериям
    [PricingPlans] varchar  NOT NULL ,
    CONSTRAINT [PK_TypeOfPolicy] PRIMARY KEY CLUSTERED (
        [TypeID] ASC
    )
)

-- Оформленные полисы
CREATE TABLE [Policy] (
    [PolicyID] int  NOT NULL ,
    [TypeOfPolicy] int  NOT NULL ,
    [Status] int  NOT NULL ,
    [Agent] int  NOT NULL ,
    [Client] int  NOT NULL ,
    -- все данные по полису
    [PolicyData] varchar(max) collate Cyrillic_General_CS_AI  NOT NULL ,
    -- страховая премия
    [Premium] decimal  NOT NULL ,
    -- страховая сумма
    [Sum] decimal  NOT NULL ,
    CONSTRAINT [PK_Policy] PRIMARY KEY CLUSTERED (
        [PolicyID] ASC
    )
)

-- статус полиса или стр. случая
CREATE TABLE [Status] (
    [StatusID] int  NOT NULL ,
    [StatusName] varchar(100) collate Cyrillic_General_CS_AI  NOT NULL ,
    CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED (
        [StatusID] ASC
    )
)

-- возможные страховые случаи
CREATE TABLE [Case] (
    [CaseID] int  NOT NULL ,
    [CaseName] varchar(100) collate Cyrillic_General_CS_AI  NOT NULL ,
    CONSTRAINT [PK_Case] PRIMARY KEY CLUSTERED (
        [CaseID] ASC
    )
)

-- страховые случаи
CREATE TABLE [InsuranceCases] (
    [InsuranceCaseID] int  NOT NULL ,
    [CaseID] int  NOT NULL ,
    [PolicyID] int  NOT NULL ,
    [Description] varchar(max) collate Cyrillic_General_CS_AI  NULL ,
    [Status] int  NOT NULL ,
    CONSTRAINT [PK_InsuranceCases] PRIMARY KEY CLUSTERED (
        [InsuranceCaseID] ASC
    )
)

ALTER TABLE [TypeOfPolicy] WITH CHECK ADD CONSTRAINT [FK_TypeOfPolicy_Case] FOREIGN KEY([Case])
REFERENCES [Case] ([CaseID])

ALTER TABLE [TypeOfPolicy] CHECK CONSTRAINT [FK_TypeOfPolicy_Case]

ALTER TABLE [Policy] WITH CHECK ADD CONSTRAINT [FK_Policy_TypeOfPolicy] FOREIGN KEY([TypeOfPolicy])
REFERENCES [TypeOfPolicy] ([TypeID])

ALTER TABLE [Policy] CHECK CONSTRAINT [FK_Policy_TypeOfPolicy]

ALTER TABLE [Policy] WITH CHECK ADD CONSTRAINT [FK_Policy_Status] FOREIGN KEY([Status])
REFERENCES [Status] ([StatusID])

ALTER TABLE [Policy] CHECK CONSTRAINT [FK_Policy_Status]

ALTER TABLE [Policy] WITH CHECK ADD CONSTRAINT [FK_Policy_Agent] FOREIGN KEY([Agent])
REFERENCES [Agent] ([AgentID])

ALTER TABLE [Policy] CHECK CONSTRAINT [FK_Policy_Agent]

ALTER TABLE [Policy] WITH CHECK ADD CONSTRAINT [FK_Policy_Client] FOREIGN KEY([Client])
REFERENCES [Client] ([ClientID])

ALTER TABLE [Policy] CHECK CONSTRAINT [FK_Policy_Client]

ALTER TABLE [InsuranceCases] WITH CHECK ADD CONSTRAINT [FK_InsuranceCases_CaseID] FOREIGN KEY([CaseID])
REFERENCES [Case] ([CaseID])

ALTER TABLE [InsuranceCases] CHECK CONSTRAINT [FK_InsuranceCases_CaseID]

ALTER TABLE [InsuranceCases] WITH CHECK ADD CONSTRAINT [FK_InsuranceCases_PolicyID] FOREIGN KEY([PolicyID])
REFERENCES [Policy] ([PolicyID])

ALTER TABLE [InsuranceCases] CHECK CONSTRAINT [FK_InsuranceCases_PolicyID]

ALTER TABLE [InsuranceCases] WITH CHECK ADD CONSTRAINT [FK_InsuranceCases_Status] FOREIGN KEY([Status])
REFERENCES [Status] ([StatusID])

ALTER TABLE [InsuranceCases] CHECK CONSTRAINT [FK_InsuranceCases_Status]

CREATE INDEX PolicyId ON Policy (PolicyID);


COMMIT TRANSACTION QUICKDBD