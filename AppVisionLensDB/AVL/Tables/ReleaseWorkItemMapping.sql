CREATE TABLE [AVL].[ReleaseWorkItemMapping] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [SprintDetailId] BIGINT        NOT NULL,
    [WorkTypeMapId]  BIGINT        NOT NULL,
    [IsDeleted]      BIT           NOT NULL,
    [CreatedDate]    DATETIME      NOT NULL,
    [CreatedBy]      NVARCHAR (50) NOT NULL,
    [ModifiedDate]   DATETIME      NULL,
    [ModifiedBy]     NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

