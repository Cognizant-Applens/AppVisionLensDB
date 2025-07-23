CREATE TABLE [AVL].[VersionDetails] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [Application] VARCHAR (50) NULL,
    [Version]     VARCHAR (50) NULL,
    [ReleaseDate] DATE         NULL,
    [CopyRight]   INT          NULL,
    CONSTRAINT [PK_VersionDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);

