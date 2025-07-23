CREATE TABLE [SA].[KeywordMaster] (
    [KeywordMasterID] INT            IDENTITY (1, 1) NOT NULL,
    [AssignmentGroup] NVARCHAR (100) NOT NULL,
    [Keyword]         NVARCHAR (100) NOT NULL,
    [BuisnessArea]    NVARCHAR (100) NOT NULL,
    [BusinessName]    NVARCHAR (200) NOT NULL,
    [SubjectArea]     NVARCHAR (200) DEFAULT ('') NULL,
    [ApplicationId]   BIGINT         NOT NULL,
    PRIMARY KEY CLUSTERED ([KeywordMasterID] ASC)
);

