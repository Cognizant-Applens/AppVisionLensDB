CREATE TABLE [dbo].[AutoClassificationDetailsHistory] (
    [AutoClassificationDetailsHistoryID] INT           IDENTITY (1, 1) NOT NULL,
    [AutoClassificationDetailsID]        INT           NULL,
    [Remarks]                            VARCHAR (MAX) NULL,
    [CreatedBy]                          VARCHAR (100) NULL,
    [CreatedDate]                        DATETIME      NULL,
    [ModifiedBy]                         VARCHAR (100) NULL,
    [ModifiedDate]                       DATE          NULL
);

