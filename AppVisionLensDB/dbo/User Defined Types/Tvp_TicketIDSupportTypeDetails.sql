CREATE TYPE [dbo].[Tvp_TicketIDSupportTypeDetails] AS TABLE (
    [TicketID]      NVARCHAR (MAX) NULL,
    [SupportTypeID] INT            NULL,
    [Type]          CHAR (1)       NOT NULL,
    [WorkItemID]    NVARCHAR (100) NULL);

