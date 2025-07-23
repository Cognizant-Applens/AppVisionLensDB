CREATE TABLE [AVL].[DEBT_MAS_StandardDataDictionary] (
    [ID]                   INT          IDENTITY (1, 1) NOT NULL,
    [ClusterID]            INT          NOT NULL,
    [SubClusterID]         INT          NOT NULL,
    [CauseCodeID]          INT          NOT NULL,
    [ResolutionCodeID]     INT          NOT NULL,
    [DebtClassificationID] INT          NULL,
    [AvoidableFlagID]      INT          NULL,
    [IsDeleted]            BIT          NOT NULL,
    [CreatedBy]            VARCHAR (50) NULL,
    [CreatedDate]          DATETIME     DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           VARCHAR (50) NULL,
    [ModifiedDate]         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

