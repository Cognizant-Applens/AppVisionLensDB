CREATE TABLE [AVL].[ITSM_MAS_WarrantyIssue] (
    [WarrantyIssueId] INT           IDENTITY (1, 1) NOT NULL,
    [Warranty Issue]  VARCHAR (100) NULL,
    [CreatedBy]       NUMERIC (6)   NULL,
    [CreatedDate]     DATETIME      NULL,
    [ModifiedBy]      NUMERIC (6)   NULL,
    [ModifiedDate]    DATETIME      NULL,
    [IsDeleted]       BIT           NULL
);

