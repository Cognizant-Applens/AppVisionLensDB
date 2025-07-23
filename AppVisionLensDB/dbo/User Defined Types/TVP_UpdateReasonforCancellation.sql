CREATE TYPE [dbo].[TVP_UpdateReasonforCancellation] AS TABLE (
    [HealingTicketId]      VARCHAR (30)    NULL,
    [TicketStatusId]       INT             NULL,
    [Comments]             VARCHAR (250)   NULL,
    [ClosedDate]           VARCHAR (20)    NULL,
    [ImplementationEffort] DECIMAL (25, 2) NULL,
    [AssigneeID]           VARCHAR (20)    NULL);

