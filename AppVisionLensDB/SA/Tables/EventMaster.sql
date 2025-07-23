CREATE TABLE [SA].[EventMaster] (
    [EventId]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [EventName]             NVARCHAR (100) DEFAULT (NULL) NULL,
    [EventDescription]      NVARCHAR (100) DEFAULT (NULL) NULL,
    [EventImpact]           NVARCHAR (100) DEFAULT (NULL) NULL,
    [EventImpactStartDate]  DATE           DEFAULT (NULL) NULL,
    [EventImpactEndDate]    DATE           DEFAULT (NULL) NULL,
    [EventApplicationId]    BIGINT         NOT NULL,
    [EventServerId]         BIGINT         NOT NULL,
    [EventProcessId]        INT            NOT NULL,
    [EventTicketType]       NVARCHAR (100) NOT NULL,
    [EventImpactType]       INT            DEFAULT (NULL) NULL,
    [EventImpactPercentage] INT            DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([EventId] ASC)
);

