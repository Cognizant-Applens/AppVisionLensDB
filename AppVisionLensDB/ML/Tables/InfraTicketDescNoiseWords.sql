CREATE TABLE [ML].[InfraTicketDescNoiseWords] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]           BIGINT         NULL,
    [TicketDescNoiseWord] NVARCHAR (500) NULL,
    [Frequency]           BIGINT         NULL,
    [IsActive]            BIT            NULL,
    [CreatedDate]         DATETIME       NULL,
    [CreatedBy]           NVARCHAR (50)  NULL,
    [InitialLearningID]   BIGINT         NULL,
    [ModifiedDate]        DATETIME       NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_InfraTicketDescNoiseWords_InitialLearningID] FOREIGN KEY ([InitialLearningID]) REFERENCES [ML].[InfraConfigurationProgress] ([ID])
);

