CREATE TABLE [SA].[UserDetailsRoleLevel] (
    [UserRoleDetailsID] INT IDENTITY (1, 1) NOT NULL,
    [UserDetailsID]     INT NOT NULL,
    [RoleId]            INT NULL,
    PRIMARY KEY CLUSTERED ([UserRoleDetailsID] ASC, [UserDetailsID] ASC)
);

