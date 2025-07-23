CREATE TABLE [AVL].[UseCaseStatus] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [UseCaseStatusName] NVARCHAR (50) NOT NULL,
    [IsDeleted]         BIT           NOT NULL,
    [CreatedBy]         NVARCHAR (50) NOT NULL,
    [CreatedOn]         DATETIME      NOT NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedOn]        DATETIME      NULL,
    CONSTRAINT [PK_UseCaseStatus] PRIMARY KEY CLUSTERED ([Id] ASC)
);

