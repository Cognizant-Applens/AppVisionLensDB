CREATE TABLE [AVL].[DEBT_CatalogRuleDetails] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [CatalogLevel] VARCHAR (5)  NOT NULL,
    [ProjectData]  BIGINT       NOT NULL,
    [StandardData] INT          NULL,
    [MatchLevel]   VARCHAR (10) NOT NULL,
    [CreatedBy]    VARCHAR (30) DEFAULT ('DebtUtilitySystem') NOT NULL,
    [CreatedDate]  DATETIME     DEFAULT (getdate()) NOT NULL,
    [IsDeleted]    BIT          DEFAULT ((0)) NOT NULL,
    [ModifiedBy]   INT          NULL,
    [ModifiedDate] DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

