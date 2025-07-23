CREATE TABLE [AVL].[DEBT_ProjectCatalogMatchDetails] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [RunDate]        DATE         NOT NULL,
    [ProjectID]      BIGINT       NOT NULL,
    [CatalogLevel]   VARCHAR (5)  NOT NULL,
    [Value]          BIGINT       NOT NULL,
    [StandardDataID] INT          NULL,
    [MatchLevel]     VARCHAR (10) NOT NULL,
    [Count]          INT          NOT NULL,
    [CreatedBy]      VARCHAR (30) DEFAULT ('DebtUtilitySystem') NOT NULL,
    [CreatedDate]    DATETIME     DEFAULT (getdate()) NOT NULL,
    [IsDeleted]      BIT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

