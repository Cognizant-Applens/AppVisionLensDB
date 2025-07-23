CREATE TABLE [MS].[MAS_TicketSummaryBase_Master] (
    [TicketSummaryBaseID]   INT            IDENTITY (1, 1) NOT NULL,
    [TicketSummaryBaseName] NVARCHAR (200) NULL,
    [BaseStepID]            INT            NULL,
    [IsDeleted]             BIT            NULL,
    CONSTRAINT [PK_TicketSummaryBase_Master] PRIMARY KEY CLUSTERED ([TicketSummaryBaseID] ASC) WITH (FILLFACTOR = 70)
);

