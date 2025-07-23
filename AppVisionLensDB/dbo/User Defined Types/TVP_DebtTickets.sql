CREATE TYPE [dbo].[TVP_DebtTickets] AS TABLE (
    [TicketId]             NVARCHAR (MAX) NULL,
    [TicketDescription]    NVARCHAR (MAX) NULL,
    [ApplicationID]        NVARCHAR (MAX) NULL,
    [DebtClassificationId] NVARCHAR (MAX) NULL,
    [AvoidableFlagId]      NVARCHAR (MAX) NULL,
    [CauseCode]            NVARCHAR (MAX) NULL,
    [ResolutionCode]       NVARCHAR (MAX) NULL,
    [ResidualDebtId]       NVARCHAR (MAX) NULL,
    [OptionalField]        NVARCHAR (MAX) NULL);

