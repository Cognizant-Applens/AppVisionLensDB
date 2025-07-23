CREATE TABLE [AVL].[UseCaseServiceLevelDetails] (
    [Id]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [UseCaseDetailId] INT           NOT NULL,
    [ServiceLevelID]  INT           NOT NULL,
    [IsDeleted]       BIT           NULL,
    [CreatedBy]       NVARCHAR (50) NULL,
    [CreatedDate]     DATETIME      NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    CONSTRAINT [PK_UseCaseServiceDetails] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UseCaseServiceLevelDetails_UseCaseDetails] FOREIGN KEY ([UseCaseDetailId]) REFERENCES [AVL].[UseCaseDetails] ([Id])
);

