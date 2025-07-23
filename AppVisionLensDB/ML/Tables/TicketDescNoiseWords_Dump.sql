CREATE TABLE [ML].[TicketDescNoiseWords_Dump] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]           BIGINT         NULL,
    [InitialLearningID]   BIGINT         NULL,
    [TicketDescNoiseWord] NVARCHAR (500) NULL,
    [Frequency]           BIGINT         NULL,
    [IsActive]            BIT            NULL,
    [CreatedDate]         DATETIME       NULL,
    [CreatedBy]           NVARCHAR (500) NULL,
    [ModifiedDate]        DATETIME       NULL,
    [ModifiedBy]          NVARCHAR (500) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_ProjectID]
    ON [ML].[TicketDescNoiseWords_Dump]([ProjectID] ASC);

