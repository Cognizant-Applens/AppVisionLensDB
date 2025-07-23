CREATE TYPE [dbo].[TVP_UpdateticketDetailsDescription] AS TABLE (
    [TicketID]          NVARCHAR (100) NOT NULL,
    [ProjectID]         BIGINT         NULL,
    [TicketDescription] NVARCHAR (MAX) NULL);

