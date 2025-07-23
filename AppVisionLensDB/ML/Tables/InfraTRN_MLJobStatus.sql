CREATE TABLE [ML].[InfraTRN_MLJobStatus] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]         BIGINT         NULL,
    [InitialLearningID] BIGINT         NULL,
    [JobIdFromML]       NVARCHAR (50)  NULL,
    [InitiatedBy]       VARCHAR (50)   NULL,
    [JobMessage]        NVARCHAR (MAX) NULL,
    [JobType]           NVARCHAR (20)  NULL,
    [CreatedOn]         DATETIME       NULL,
    [CreatedBy]         NVARCHAR (50)  NULL,
    [ModifiedOn]        DATETIME       NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [IsDeleted]         BIT            NULL,
    [IsDARTProcessed]   NVARCHAR (10)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

