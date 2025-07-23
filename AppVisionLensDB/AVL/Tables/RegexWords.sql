CREATE TABLE [AVL].[RegexWords] (
    [RegexWordID]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]    BIGINT         NOT NULL,
    [RegexWord]    NVARCHAR (MAX) NOT NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED ([RegexWordID] ASC),
    CONSTRAINT [FK_ProjectIDRegex] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

