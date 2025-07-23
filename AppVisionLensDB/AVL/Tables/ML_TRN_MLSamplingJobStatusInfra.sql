CREATE TABLE [AVL].[ML_TRN_MLSamplingJobStatusInfra] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]         BIGINT         NOT NULL,
    [InitialLearningID] BIGINT         NULL,
    [JobIdFromML]       NVARCHAR (MAX) NULL,
    [FileName]          NVARCHAR (MAX) NULL,
    [DataPath]          NVARCHAR (MAX) NULL,
    [DARTJobStatus]     NVARCHAR (MAX) NULL,
    [InitiatedBy]       NVARCHAR (MAX) NULL,
    [JobMessage]        NVARCHAR (MAX) NULL,
    [JobType]           NVARCHAR (20)  NULL,
    [IsDARTProcessed]   NVARCHAR (10)  NULL,
    [MLSamplingStatus]  NVARCHAR (10)  NULL,
    [RetryCount]        INT            NULL,
    [IsDeleted]         BIT            NULL,
    [CreatedBy]         NVARCHAR (50)  NULL,
    [CreatedDate]       DATETIME       NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

