CREATE TABLE [ML].[OptionalFieldNoiseWords] (
    [ID]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]              BIGINT         NULL,
    [InitialLearningID]      BIGINT         NULL,
    [OptionalFieldNoiseWord] NVARCHAR (500) NULL,
    [Frequency]              BIGINT         NULL,
    [IsActive]               BIT            NULL,
    [CreatedDate]            DATETIME       NULL,
    [CreatedBy]              NVARCHAR (500) NULL,
    [ModifiedDate]           DATETIME       NULL,
    [ModifiedBy]             NVARCHAR (500) NULL,
    [Source]                 VARCHAR (50)   DEFAULT ('LearningWeb') NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

