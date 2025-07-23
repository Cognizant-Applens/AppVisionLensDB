CREATE TYPE [AVL].[CL_CLPatterns] AS TABLE (
    [ID]              BIGINT         NULL,
    [DebtID]          INT            NULL,
    [AvoidableFlagID] INT            NULL,
    [ResidualID]      INT            NULL,
    [CauseCodeID]     INT            NULL,
    [ApprovedOrMuted] INT            NULL,
    [EmployeeID]      NVARCHAR (300) NULL,
    [IsCLSignOff]     BIT            NULL);

