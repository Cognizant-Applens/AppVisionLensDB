CREATE TABLE [SA].[CriticalProcessStages] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [StageName]        VARCHAR (100)  NOT NULL,
    [StageType]        NVARCHAR (100) NULL,
    [StartTime]        TIME (7)       NULL,
    [EndTime]          TIME (7)       NULL,
    [ExpectedDuration] INT            NULL,
    [LogFileName]      NVARCHAR (100) NULL,
    [LogFilePath]      NVARCHAR (100) NULL,
    [MasterSource]     VARCHAR (45)   NULL,
    [ExpectedCount]    INT            NULL,
    [MinimumCount]     INT            NULL,
    [MaximumCount]     INT            NULL,
    [CreatedBy]        NVARCHAR (10)  NULL,
    [CreatedOn]        DATETIME       NULL,
    [ModifiedBy]       NVARCHAR (10)  NULL,
    [ModifiedOn]       DATETIME       NULL,
    [IsActive]         BIT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)
);

