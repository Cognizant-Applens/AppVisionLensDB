CREATE TABLE [AVL].[UserDetailsRoleMapping] (
    [UserModuleRoleMapID] INT            IDENTITY (1, 1) NOT NULL,
    [UserId]              NVARCHAR (45)  NOT NULL,
    [ModuleID]            NVARCHAR (70)  NOT NULL,
    [RoleID]              NVARCHAR (200) NOT NULL,
    PRIMARY KEY CLUSTERED ([UserModuleRoleMapID] ASC)
);

