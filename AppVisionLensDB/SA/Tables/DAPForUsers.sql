CREATE TABLE [SA].[DAPForUsers] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [UserId]     INT           NOT NULL,
    [DAPId]      INT           NOT NULL,
    [CreatedBy]  NVARCHAR (10) NULL,
    [CreatedOn]  DATETIME      NULL,
    [ModifiedBy] NVARCHAR (10) NULL,
    [ModifiedOn] DATETIME      NULL,
    [IsActive]   BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_DAPForUsers_DAPProfile] FOREIGN KEY ([DAPId]) REFERENCES [SA].[DAPProfile] ([DAPId]),
    CONSTRAINT [FK_DAPForUsers_MAS_LoginMaster] FOREIGN KEY ([UserId]) REFERENCES [AVL].[MAS_LoginMaster] ([UserID])
);

