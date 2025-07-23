CREATE TABLE [ADM].[MAS_BugType] (
    [BugTypeId]    SMALLINT       IDENTITY (1, 1) NOT NULL,
    [BugType]      NVARCHAR (100) NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([BugTypeId] ASC)
);

