CREATE TABLE [BOT].[ProblemType] (
    [Id]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProblemType]  NVARCHAR (200) NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

