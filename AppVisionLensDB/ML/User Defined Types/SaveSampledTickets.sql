CREATE TYPE [ML].[SaveSampledTickets] AS TABLE (
    [TicketId]             NVARCHAR (MAX) NULL,
    [CauseCodeId]          INT            NULL,
    [ResolutionCodeID]     INT            NULL,
    [DebtClassificationID] INT            NULL,
    [AvoidableFlagID]      INT            NULL,
    [ResidualDebtID]       INT            NULL);

