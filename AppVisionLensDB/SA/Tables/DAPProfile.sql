CREATE TABLE [SA].[DAPProfile] (
    [DAPId]       INT            IDENTITY (1, 1) NOT NULL,
    [DAPName]     NVARCHAR (50)  NOT NULL,
    [Description] NVARCHAR (500) NOT NULL,
    [CreatedBy]   NVARCHAR (10)  NULL,
    [CreatedOn]   DATETIME       NULL,
    [ModifiedBy]  NVARCHAR (10)  NULL,
    [ModifiedOn]  DATETIME       NULL,
    [IsActive]    BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([DAPId] ASC) WITH (FILLFACTOR = 80)
);

