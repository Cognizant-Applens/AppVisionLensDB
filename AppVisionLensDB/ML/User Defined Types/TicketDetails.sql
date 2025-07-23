CREATE TYPE [ML].[TicketDetails] AS TABLE (
    [TicketID]                   NVARCHAR (50)  NOT NULL,
    [TicketDescription]          NVARCHAR (MAX) NULL,
    [ResolutionRemarks]          NVARCHAR (MAX) NULL,
    [IsTicketDescriptionUpdated] BIT            NULL,
    [IsResolutionRemarksUpdated] BIT            NULL);

