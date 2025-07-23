CREATE TABLE [dbo].[ProjectMigrationInfo_L2Team] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [OldEsaProjectID]     NVARCHAR (100)  NOT NULL,
    [NewEsaProjectID]     NVARCHAR (100)  NOT NULL,
    [OldApplensProjectID] BIGINT          NOT NULL,
    [NewApplensProjectID] BIGINT          NOT NULL,
    [OldProjectName]      NVARCHAR (100)  NULL,
    [NewProjectName]      NVARCHAR (100)  NULL,
    [RequestedBy]         NVARCHAR (100)  NULL,
    [RequestedDate]       DATETIME        NULL,
    [MigratedDate]        DATETIME        NOT NULL,
    [CreatedDate]         DATETIME        NULL,
    [CreatedBy]           NVARCHAR (100)  NULL,
    [Comments]            NVARCHAR (1000) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

