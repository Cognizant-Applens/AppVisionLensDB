CREATE TYPE [dbo].[TVP_TicketSubmit] AS TABLE (
    [TicketId]      NVARCHAR (1000) NULL,
    [ProjectID]     BIGINT          NULL,
    [ApplicationID] BIGINT          NULL,
    [StatusID]      BIGINT          NULL,
    [UserID]        BIGINT          NULL,
    [TicketTypeID]  BIGINT          NULL);

