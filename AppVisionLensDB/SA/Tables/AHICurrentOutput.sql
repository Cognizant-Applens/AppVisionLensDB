CREATE TABLE [SA].[AHICurrentOutput] (
    [CurrentOutputId]              INT             IDENTITY (1, 1) NOT NULL,
    [CurrentOutputName]            NVARCHAR (255)  DEFAULT (NULL) NULL,
    [CurrentOutputRank]            INT             DEFAULT (NULL) NULL,
    [CurrentOutputMonth]           NVARCHAR (50)   DEFAULT (NULL) NULL,
    [CurrentOutputArea]            DECIMAL (18, 2) DEFAULT (NULL) NULL,
    [CurrentOutputVariation]       NVARCHAR (50)   DEFAULT (NULL) NULL,
    [CurrentOutputFunctionalGroup] NVARCHAR (100)  DEFAULT (NULL) NULL,
    [CurrentOutputCreatedOn]       DATETIME        DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([CurrentOutputId] ASC)
);

