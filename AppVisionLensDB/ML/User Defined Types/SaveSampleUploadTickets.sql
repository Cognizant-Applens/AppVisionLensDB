CREATE TYPE [ML].[SaveSampleUploadTickets] AS TABLE (
    [TicketId]                    NVARCHAR (MAX)  NULL,
    [ApplicationName]             NVARCHAR (MAX)  NULL,
    [TicketDescription]           NVARCHAR (MAX)  NULL,
    [AdditionalText]              NVARCHAR (MAX)  NULL,
    [CauseCode]                   NVARCHAR (500)  NULL,
    [ResolutionCode]              NVARCHAR (500)  NULL,
    [DebtClassificationName]      NVARCHAR (500)  NULL,
    [AvoidableFlagName]           NVARCHAR (5)    NULL,
    [ResidualDebt]                NVARCHAR (5)    NULL,
    [TicketDescriptionPattern]    NVARCHAR (1000) NULL,
    [TicketDescriptionSubPattern] NVARCHAR (1000) NULL,
    [RemarksPatternsResolution]   NVARCHAR (1000) NULL,
    [ResolutionRemarkssubPattern] NVARCHAR (1000) NULL);

