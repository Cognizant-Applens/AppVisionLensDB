CREATE TYPE [dbo].[TVP_TicketCollection] AS TABLE (
    [TicketDescription]   NVARCHAR (MAX) NULL,
    [ProjectPatternMapID] BIGINT         NULL,
    [TicketType]          NVARCHAR (MAX) NULL,
    [HealingTicketID]     NVARCHAR (MAX) NULL);

