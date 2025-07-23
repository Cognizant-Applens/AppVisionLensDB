CREATE TABLE [MAS].[DataPurgeActvityMaster] (
    [ID]                  INT            IDENTITY (1, 1) NOT NULL,
    [ServerName]          NVARCHAR (25)  NOT NULL,
    [DatabaseName]        VARCHAR (25)   NOT NULL,
    [TableName]           NVARCHAR (100) NOT NULL,
    [ConditionColumnName] VARCHAR (25)   NOT NULL,
    [DataRetainedDays]    INT            NOT NULL,
    [CreatedBy]           NVARCHAR (10)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ScheduledFrequency]  NVARCHAR (25)  NOT NULL,
    [LastProcessedDate]   DATETIME       NULL,
    [IsDeleted]           BIT            NOT NULL
);

