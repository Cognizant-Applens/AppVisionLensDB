CREATE TYPE [dbo].[TVP_SaveDebtSampleTickets] AS TABLE (
    [TicketId]             NVARCHAR (MAX)  NULL,
    [TicketDescription]    NVARCHAR (MAX)  NULL,
    [AdditionalText]       NVARCHAR (MAX)  NULL,
    [DebtClassificationId] NVARCHAR (MAX)  NULL,
    [AvoidableFlagId]      NVARCHAR (MAX)  NULL,
    [ResidualDebtId]       NVARCHAR (MAX)  NULL,
    [CauseCodeId]          NVARCHAR (MAX)  NULL,
    [ResolutionCodeId]     NVARCHAR (MAX)  NULL,
    [DescBaseWorkPattern]  NVARCHAR (1000) NULL,
    [DescSubWorkPattern]   NVARCHAR (1000) NULL,
    [ResBaseWorkPattern]   NVARCHAR (1000) NULL,
    [ResSubWorkPattern]    NVARCHAR (1000) NULL,
    [ApplicationID]        NVARCHAR (MAX)  NULL);

