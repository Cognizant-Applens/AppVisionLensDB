CREATE TABLE [AVL].[RoleScreenMapping] (
    [RoleScreenMapId] INT            IDENTITY (1, 1) NOT NULL,
    [RoleId]          INT            NOT NULL,
    [ScreenId]        INT            NOT NULL,
    [TypeOfAccess]    CHAR (1)       NOT NULL,
    [Isactive]        BIT            NOT NULL,
    [CreatedOn]       DATETIME       NOT NULL,
    [CreatedBy]       NVARCHAR (255) NOT NULL,
    [ModifiedOn]      DATETIME       NULL,
    [ModifiedBy]      NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([RoleScreenMapId] ASC)
);

