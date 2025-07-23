CREATE TABLE [SA].[BusinessCriticallityScore] (
    [BusinessCriticallityScoreID] INT           IDENTITY (1, 1) NOT NULL,
    [business_criticallity]       VARCHAR (100) NOT NULL,
    [score]                       INT           DEFAULT (NULL) NULL,
    [ColorCode]                   VARCHAR (100) DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([BusinessCriticallityScoreID] ASC)
);

