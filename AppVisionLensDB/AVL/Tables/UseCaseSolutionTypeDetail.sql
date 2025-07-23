CREATE TABLE [AVL].[UseCaseSolutionTypeDetail] (
    [Id]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [UseCaseDetailId] INT           NOT NULL,
    [SolutionTypeID]  BIGINT        NOT NULL,
    [IsDeleted]       BIT           NOT NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDate]     DATETIME      NOT NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    CONSTRAINT [PK_UseCaseSolutionTypeDetail] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UseCaseSolutionTypeDetail_UseCaseSolutionTypeDetail] FOREIGN KEY ([UseCaseDetailId]) REFERENCES [AVL].[UseCaseDetails] ([Id])
);

