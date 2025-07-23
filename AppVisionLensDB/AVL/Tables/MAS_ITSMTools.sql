CREATE TABLE [AVL].[MAS_ITSMTools] (
    [ITSMID]         INT            IDENTITY (1, 1) NOT NULL,
    [ITSMName]       NVARCHAR (MAX) NULL,
    [IsDeleted]      BIT            NULL,
    [CreatedBy]      NVARCHAR (MAX) NULL,
    [CreatedDate]    DATETIME       NULL,
    [IsCustomerTool] INT            DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([ITSMID] ASC)
);

