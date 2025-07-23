CREATE TYPE [dbo].[TVP_DebtTicketsInfra] AS TABLE (
    [TicketId]             NVARCHAR (50)  NULL,
    [TicketDescription]    NVARCHAR (MAX) NULL,
    [TowerID]              BIGINT         NULL,
    [DebtClassificationId] INT            NULL,
    [AvoidableFlagId]      INT            NULL,
    [CauseCode]            BIGINT         NULL,
    [ResolutionCode]       BIGINT         NULL,
    [ResidualDebtId]       INT            NULL,
    [OptionalField]        NVARCHAR (MAX) NULL);

