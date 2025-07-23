CREATE TABLE [ML].[InfraOptionalFieldNoiseWords] (
    [ID]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]              BIGINT         NULL,
    [OptionalFieldNoiseWord] NVARCHAR (500) NULL,
    [Frequency]              BIGINT         NULL,
    [IsActive]               BIT            NULL,
    [CreatedDate]            DATETIME       NULL,
    [CreatedBy]              NVARCHAR (50)  NULL,
    [InitialLearningID]      BIGINT         NULL,
    [ModifiedDate]           DATETIME       NULL,
    [ModifiedBy]             NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_InfraOptionalFieldNoiseWords_InitialLearningID] FOREIGN KEY ([InitialLearningID]) REFERENCES [ML].[InfraConfigurationProgress] ([ID])
);

