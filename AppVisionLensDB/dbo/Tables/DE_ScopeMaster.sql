CREATE TABLE [dbo].[DE_ScopeMaster] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [DE_Scope]    NVARCHAR (20) NULL,
    [DE_Scope_ID] INT           NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

