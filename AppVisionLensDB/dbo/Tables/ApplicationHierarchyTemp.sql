CREATE TABLE [dbo].[ApplicationHierarchyTemp] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [Hierarchy1]      VARCHAR (500) NOT NULL,
    [Hierarchy2]      VARCHAR (500) NOT NULL,
    [Hierarchy3]      VARCHAR (500) NOT NULL,
    [Hierarchy4]      VARCHAR (500) NULL,
    [Hierarchy5]      VARCHAR (500) NULL,
    [Hierarchy6]      VARCHAR (500) NULL,
    [ApplicationName] VARCHAR (500) NULL,
    [CustomerId]      BIGINT        NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

