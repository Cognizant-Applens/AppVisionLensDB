CREATE TABLE [AVL].[Debt_MAS_ProjectDataDictionary] (
    [ID]                     INT          IDENTITY (1, 1) NOT NULL,
    [ProjectID]              INT          NOT NULL,
    [ApplicationID]          INT          NOT NULL,
    [CauseCodeID]            INT          NOT NULL,
    [ResolutionCodeID]       INT          NOT NULL,
    [DebtClassificationID]   INT          NULL,
    [AvoidableFlagID]        INT          NULL,
    [ResidualDebtID]         INT          NULL,
    [ReasonForResidual]      INT          NULL,
    [ExpectedCompletionDate] DATETIME     NULL,
    [IsDeleted]              BIT          CONSTRAINT [DF_Debt_MAS_ProjectDataDictionary_IsDeleted] DEFAULT ((0)) NULL,
    [EffectiveDate]          DATETIME     NULL,
    [CreatedBy]              VARCHAR (50) NULL,
    [CreatedDate]            DATETIME     NULL,
    [ModifiedBy]             VARCHAR (50) NULL,
    [ModifiedDate]           DATETIME     NULL,
    [IsAll]                  INT          NULL,
    [IsPatternFromJob]       BIT          NULL,
    CONSTRAINT [PK_Debt_MAS_ProjectDataDictionary] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_PrjID_IsDeleted]
    ON [AVL].[Debt_MAS_ProjectDataDictionary]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([ApplicationID], [CauseCodeID], [ResolutionCodeID], [DebtClassificationID], [AvoidableFlagID], [ResidualDebtID]);


GO
CREATE NONCLUSTERED INDEX [IX_ProjectID_ApplicationID]
    ON [AVL].[Debt_MAS_ProjectDataDictionary]([ProjectID] ASC, [ApplicationID] ASC, [CauseCodeID] ASC, [ResolutionCodeID] ASC, [DebtClassificationID] ASC, [AvoidableFlagID] ASC, [ResidualDebtID] ASC)
    INCLUDE([ReasonForResidual], [ExpectedCompletionDate], [IsDeleted], [EffectiveDate], [CreatedBy], [CreatedDate], [IsAll]);

