CREATE TABLE [ML].[ClusteringCLProjects] (
    [ClusterCLID]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]        BIGINT         NOT NULL,
    [TransactionID]    BIGINT         NOT NULL,
    [JobRunDate]       DATETIME       NOT NULL,
    [SupportTypeId]    SMALLINT       NOT NULL,
    [JobStatusKey]     NVARCHAR (6)   NULL,
    [JobMessage]       NVARCHAR (MAX) NULL,
    [IsDeleted]        BIT            NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    [IsManual]         BIT            DEFAULT ((0)) NOT NULL,
    [ManualJobMessage] NVARCHAR (MAX) NULL,
    [ManualJobKey]     NVARCHAR (6)   NULL,
    [IsRegenerate]     BIT            DEFAULT ((0)) NULL,
    [RegeneratedDate]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ClusterCLID] ASC),
    FOREIGN KEY ([TransactionID]) REFERENCES [ML].[TRN_MLTransaction] ([TransactionId])
);

