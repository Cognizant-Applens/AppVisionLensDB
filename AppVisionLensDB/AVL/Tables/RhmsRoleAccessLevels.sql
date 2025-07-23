CREATE TABLE [AVL].[RhmsRoleAccessLevels] (
    [RhmsRoleId]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [RhmsRoleName] NVARCHAR (200) NOT NULL,
    [AccessLevel]  NVARCHAR (200) NOT NULL,
    [AppLensRole]  NVARCHAR (50)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_RhmsRoleName_AccessLevel_AppLensRole]
    ON [AVL].[RhmsRoleAccessLevels]([RhmsRoleName] ASC, [AccessLevel] ASC, [AppLensRole] ASC);

