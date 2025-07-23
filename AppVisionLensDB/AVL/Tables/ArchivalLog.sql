CREATE TABLE [AVL].[ArchivalLog] (
    [ArchivalLogID]   INT            IDENTITY (1, 1) NOT NULL,
    [Date]            DATETIME       NULL,
    [ArchivalDate]    DATETIME       NULL,
    [IsProjectActive] BIT            NULL,
    [ArchivalMode]    CHAR (1)       NULL,
    [UserId]          NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ArchivalLogID] ASC)
);

