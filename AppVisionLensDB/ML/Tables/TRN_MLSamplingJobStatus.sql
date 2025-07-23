CREATE TABLE [ML].[TRN_MLSamplingJobStatus] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]         BIGINT         NULL,
    [InitialLearningID] BIGINT         NULL,
    [JobIdFromML]       NVARCHAR (MAX) NULL,
    [FileName]          NVARCHAR (MAX) NULL,
    [DataPath]          NVARCHAR (MAX) NULL,
    [DARTJobStatus]     NVARCHAR (50)  NULL,
    [InitiatedBy]       VARCHAR (50)   NULL,
    [JobMessage]        NVARCHAR (MAX) NULL,
    [JobType]           NVARCHAR (20)  NULL,
    [CreatedOn]         DATETIME       NULL,
    [CreatedBy]         NVARCHAR (50)  NULL,
    [ModifiedOn]        DATETIME       NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [IsDARTProcessed]   NVARCHAR (10)  NULL,
    [MLSamplingStatus]  NVARCHAR (10)  NULL,
    [RetryCount]        INT            NULL,
    [IsDeleted]         BIT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

