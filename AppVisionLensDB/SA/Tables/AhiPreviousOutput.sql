CREATE TABLE [SA].[AhiPreviousOutput] (
    [PreviousOuputId]              INT             IDENTITY (1, 1) NOT NULL,
    [PreviousOuputName]            VARCHAR (255)   NULL,
    [PreviousOuputRank]            INT             NULL,
    [PreviousOuputMonth]           VARCHAR (50)    NULL,
    [PreviousOuputArea]            DECIMAL (18, 2) NULL,
    [PreviousOuputVariation]       VARCHAR (50)    NULL,
    [PreviousOuputFunctionalGroup] VARCHAR (100)   NULL,
    [PreviousOuputCreatedOn]       DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([PreviousOuputId] ASC)
);

