CREATE TABLE [AVL].[ML_TicketDescNoiseWords] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]           BIGINT         NULL,
    [TicketDescNoiseWord] NVARCHAR (500) NULL,
    [Frequency]           BIGINT         NULL,
    [IsActive]            BIT            NULL,
    [CreatedDate]         DATETIME       NULL,
    [CreatedBy]           NVARCHAR (500) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

