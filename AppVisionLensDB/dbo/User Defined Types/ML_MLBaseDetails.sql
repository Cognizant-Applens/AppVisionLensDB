CREATE TYPE [dbo].[ML_MLBaseDetails] AS TABLE (
    [TicketID]                    NVARCHAR (MAX) NULL,
    [ApplicationName]             NVARCHAR (MAX) NULL,
    [DebtClassification]          NVARCHAR (MAX) NULL,
    [AvoidableFlag]               NVARCHAR (MAX) NULL,
    [ResidualDebt]                NVARCHAR (MAX) NULL,
    [CauseCode]                   NVARCHAR (MAX) NULL,
    [ResolutionCode]              NVARCHAR (MAX) NULL,
    [TicketDescriptionPattern]    NVARCHAR (MAX) NULL,
    [TicketDescriptionSubPattern] NVARCHAR (MAX) NULL,
    [OptionalFieldpattern]        NVARCHAR (MAX) NULL,
    [OptionalFieldSubPattern]     NVARCHAR (MAX) NULL);

