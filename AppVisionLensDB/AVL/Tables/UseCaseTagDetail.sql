CREATE TABLE [AVL].[UseCaseTagDetail] (
    [Id]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [UseCaseDetailId] INT           NOT NULL,
    [Tag]             NVARCHAR (25) NOT NULL,
    [IsDeleted]       BIT           NOT NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDate]     DATETIME      NOT NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    CONSTRAINT [PK_UseCaseTagDetail] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UseCaseTagDetail_UseCaseDetails] FOREIGN KEY ([UseCaseDetailId]) REFERENCES [AVL].[UseCaseDetails] ([Id])
);

