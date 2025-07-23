CREATE TABLE [AVL].[DDConflictPatterns] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [ProjectID]            BIGINT        NOT NULL,
    [ApplicationID]        BIGINT        NOT NULL,
    [CauseCodeID]          BIGINT        NOT NULL,
    [ResolutionCodeID]     BIGINT        NOT NULL,
    [DebtClassificationID] BIGINT        NOT NULL,
    [AvoidableFlagID]      BIGINT        NOT NULL,
    [ResidualDebtID]       BIGINT        NOT NULL,
    [NoOfOccurence]        BIGINT        NOT NULL,
    [IsDeleted]            BIT           NOT NULL,
    [CreatedBy]            NVARCHAR (50) NOT NULL,
    [CreatedDate]          DATETIME      NOT NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_DDConflictPatterns_ProjectID]
    ON [AVL].[DDConflictPatterns]([ProjectID] ASC, [ApplicationID] ASC, [CauseCodeID] ASC, [ResolutionCodeID] ASC, [DebtClassificationID] ASC, [AvoidableFlagID] ASC, [ResidualDebtID] ASC, [IsDeleted] ASC);

