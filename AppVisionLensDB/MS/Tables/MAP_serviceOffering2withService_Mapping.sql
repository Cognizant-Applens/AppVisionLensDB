CREATE TABLE [MS].[MAP_serviceOffering2withService_Mapping] (
    [MainSpringServiceMapID] INT IDENTITY (1, 1) NOT NULL,
    [ServiceOffering2ID]     INT NOT NULL,
    [ServiceID]              INT NOT NULL,
    CONSTRAINT [PK_serviceOffering2withService_Mapping] PRIMARY KEY CLUSTERED ([MainSpringServiceMapID] ASC) WITH (FILLFACTOR = 70)
);

