CREATE TABLE [MAS].[RetrospectionCategory] (
    [CategoryId] INT           IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (50) NOT NULL,
    [Isdeleted]  BIT           NOT NULL,
    [CreatedBy]  NVARCHAR (50) NOT NULL,
    [CreatedOn]  DATETIME      NOT NULL,
    [ModifiedBy] NVARCHAR (50) NULL,
    [ModifiedOn] DATETIME      NULL,
    CONSTRAINT [PK_RetrospectionCategory] PRIMARY KEY CLUSTERED ([CategoryId] ASC)
);

