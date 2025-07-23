CREATE TYPE [dbo].[TVP_MLTicketDescWordList] AS TABLE (
    [TicketDesFieldNoiseWord] NVARCHAR (500) NULL,
    [Frequency]               BIGINT         NULL,
    [IsActive]                BIT            NULL,
    [IsDeleted]               BIT            NULL);

