CREATE TABLE [SA].[ServerMeasureMaster] (
    [Id]         BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (100) NOT NULL,
    [CreatedBy]  NVARCHAR (10)  NULL,
    [CreatedOn]  DATETIME       NULL,
    [ModifiedBy] NVARCHAR (10)  NULL,
    [ModifiedOn] DATETIME       NULL,
    [IsActive]   BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)
);

