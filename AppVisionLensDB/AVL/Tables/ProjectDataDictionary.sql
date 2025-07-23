CREATE TABLE [AVL].[ProjectDataDictionary] (
    [ID]                   INT          IDENTITY (1, 1) NOT NULL,
    [ProjectID]            INT          NOT NULL,
    [CauseCodeID]          INT          NOT NULL,
    [ResolutionCodeID]     INT          NOT NULL,
    [DebtClassificationID] INT          NOT NULL,
    [AvoidableFlagID]      INT          NOT NULL,
    [IsDeleted]            BIT          DEFAULT ((0)) NOT NULL,
    [CreatedBy]            VARCHAR (30) DEFAULT ('DebtUtilitySystem') NOT NULL,
    [CreatedDate]          DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

