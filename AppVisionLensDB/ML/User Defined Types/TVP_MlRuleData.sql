CREATE TYPE [ML].[TVP_MlRuleData] AS TABLE (
    [ID]                     BIGINT          NULL,
    [IsApprovedorMute]       INT             NULL,
    [ApplicationID]          BIGINT          NULL,
    [MLResolutionCodeID]     INT             NULL,
    [MLCauseCodeID]          INT             NULL,
    [MLAvoidableFlagID]      INT             NULL,
    [MLDebtClassificationID] INT             NULL,
    [MLResidualFlagID]       INT             NULL,
    [CreatedBy]              VARCHAR (50)    NULL,
    [InitialLearningID]      INT             NULL,
    [DescriptionBasePattern] NVARCHAR (1000) NULL,
    [DescriptionSubPattern]  NVARCHAR (1000) NULL,
    [AdditionalBasePattern]  NVARCHAR (1000) NULL,
    [AdditionalSubPattern]   NVARCHAR (1000) NULL);

