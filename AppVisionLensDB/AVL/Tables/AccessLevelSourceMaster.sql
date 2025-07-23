CREATE TABLE [AVL].[AccessLevelSourceMaster] (
    [AccessLevelSourceID] INT           IDENTITY (1, 1) NOT NULL,
    [AccessLevel]         NVARCHAR (50) NOT NULL,
    CONSTRAINT [pk_accessid] PRIMARY KEY CLUSTERED ([AccessLevelSourceID] ASC)
);

