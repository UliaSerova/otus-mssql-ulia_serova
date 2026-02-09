// для получения данных по id агента
CREATE NONCLUSTERED INDEX [FK_Agents_AgentID_AgentName] 
ON [Insuranse].[dbo].[Agent]
(
	[AgentID] ASC
)
INCLUDE(AgentName);
GO

CREATE NONCLUSTERED INDEX [FK_Clients_ClientID_ClientName] 
ON [Insuranse].[dbo].[Client]
(
	[ClientID] ASC
)
INCLUDE(ClientName);
GO

CREATE FULLTEXT CATALOG PolicyCatalog
     WITH ACCENT_SENSITIVITY = ON
     AS DEFAULT
     AUTHORIZATION dbo
   GO   

// для поиска по объекту полиса
CREATE FULLTEXT INDEX 
ON [dbo].[Policy](PolicyData)
key Index PK_Policy