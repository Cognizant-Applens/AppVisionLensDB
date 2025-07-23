CREATE TABLE [AVL].[ISpaceJobStatus] (
    [Id]           INT      IDENTITY (1, 1) NOT NULL,
    [JobStatus]    INT      NULL,
    [JobDate]      DATETIME NULL,
    [CreatedDate]  DATETIME NULL,
    [ModifiedDate] DATETIME NULL,
    CONSTRAINT [PK_ISpaceJobStatus] PRIMARY KEY CLUSTERED ([Id] ASC)
);

