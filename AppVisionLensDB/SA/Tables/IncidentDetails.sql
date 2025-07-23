CREATE TABLE [SA].[IncidentDetails] (
    [IncidentNumber] NVARCHAR (50)  NOT NULL,
    [BusinessName]   NVARCHAR (100) NOT NULL,
    [Category]       NVARCHAR (100) NULL,
    [ServiceCatalog] NVARCHAR (100) NULL,
    [SupportRole]    NVARCHAR (100) NULL,
    [Technology]     NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([IncidentNumber] ASC)
);

