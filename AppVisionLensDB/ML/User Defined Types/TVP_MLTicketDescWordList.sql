CREATE TYPE [ML].[TVP_MLTicketDescWordList] AS TABLE (
    [ID]                      BIGINT         NULL,
    [TicketDesFieldNoiseWord] NVARCHAR (500) NULL,
    [Frequency]               BIGINT         NULL,
    [IsActive]                BIT            NULL);

