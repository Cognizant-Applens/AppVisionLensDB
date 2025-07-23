CREATE TYPE [dbo].[TVP_ProjectDataDictionary] AS TABLE (
    [ID]                     INT            NULL,
    [ProjectID]              INT            NOT NULL,
    [ApplicationID]          INT            NULL,
    [CauseCodeID]            INT            NULL,
    [ResolutionCodeID]       INT            NULL,
    [DebtClassificationID]   INT            NULL,
    [AvoidableFlagID]        INT            NULL,
    [ResidualDebtID]         INT            NULL,
    [ReasonForResidual]      INT            NULL,
    [ExpectedCompletionDate] NVARCHAR (MAX) NULL,
    [CreatedBy]              NVARCHAR (100) NULL,
    [ModifiedBy]             NVARCHAR (100) NULL);

