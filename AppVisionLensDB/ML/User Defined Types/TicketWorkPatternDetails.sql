CREATE TYPE [ML].[TicketWorkPatternDetails] AS TABLE (
    [TicketID]                     NVARCHAR (50)  NOT NULL,
    [TicketDescriptionBasePattern] NVARCHAR (MAX) NULL,
    [TicketDescriptionSubPattern]  NVARCHAR (MAX) NULL,
    [ResolutionRemarksBasePattern] NVARCHAR (MAX) NULL,
    [ResolutionRemarksSubPattern]  NVARCHAR (MAX) NULL);

