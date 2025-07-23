CREATE TABLE [SA].[StartDate] (
    [StartId]           INT  IDENTITY (1, 1) NOT NULL,
    [CustomerStartDate] DATE DEFAULT (NULL) NULL,
    [CustomerStartWeek] INT  DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([StartId] ASC)
);

