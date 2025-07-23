CREATE TABLE [ADM].[SmartExecutionSharePathDetails] (
    [SharePathId]                         SMALLINT       IDENTITY (1, 1) NOT NULL,
    [ProjectID]                           BIGINT         NOT NULL,
    [WorkItemDetailsPath]                 NVARCHAR (200) NOT NULL,
    [IterationOrSprintOrPhaseDetailsPath] NVARCHAR (200) NOT NULL,
    [ReleaseDetailsPath]                  NVARCHAR (200) NOT NULL,
    [IsDeleted]                           BIT            NOT NULL,
    [CreatedBy]                           NVARCHAR (50)  NOT NULL,
    [CreatedDate]                         DATETIME       NOT NULL,
    [ModifiedBy]                          NVARCHAR (50)  NULL,
    [ModifiedDate]                        DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([SharePathId] ASC),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

