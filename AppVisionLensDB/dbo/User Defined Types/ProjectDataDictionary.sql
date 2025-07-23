CREATE TYPE [dbo].[ProjectDataDictionary] AS TABLE (
    [ProjectID]              INT      NOT NULL,
    [ApplicationID]          INT      NULL,
    [CauseCodeID]            INT      NULL,
    [ResolutionCodeID]       INT      NULL,
    [DebtClassificationID]   INT      NULL,
    [AvoidableFlagID]        INT      NULL,
    [ResidualDebtID]         INT      NULL,
    [ReasonForResidual]      INT      NULL,
    [ExpectedCompletionDate] DATETIME NULL,
    [CreatedBy]              BIGINT   NULL);

