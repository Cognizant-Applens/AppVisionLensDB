CREATE TABLE [AVL].[UserRoleMapping] (
    [UserRoleMappingID]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [EmployeeID]          NVARCHAR (50)  NOT NULL,
    [RoleID]              INT            NOT NULL,
    [AccessLevelSourceID] INT            NOT NULL,
    [AccessLevelID]       BIGINT         NULL,
    [IsActive]            BIT            NOT NULL,
    [CreatedBy]           VARCHAR (50)   NULL,
    [CreatedDate]         SMALLDATETIME  NULL,
    [ModifiedBy]          VARCHAR (50)   NULL,
    [ModifiedDate]        SMALLDATETIME  NOT NULL,
    [DataSource]          VARCHAR (100)  NULL,
    [Valid Till Date]     DATE           NULL,
    [Comments]            VARCHAR (1000) NULL,
    CONSTRAINT [FK_Accessid] FOREIGN KEY ([AccessLevelSourceID]) REFERENCES [AVL].[AccessLevelSourceMaster] ([AccessLevelSourceID]),
    CONSTRAINT [FK_Role] FOREIGN KEY ([RoleID]) REFERENCES [AVL].[RoleMaster] ([RoleId])
);


GO
CREATE NONCLUSTERED INDEX [UserRole_EmployeeID_IsActive]
    ON [AVL].[UserRoleMapping]([EmployeeID] ASC, [IsActive] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ROLE_ACCESS]
    ON [AVL].[UserRoleMapping]([RoleID] ASC, [AccessLevelID] ASC, [IsActive] ASC)
    INCLUDE([EmployeeID], [AccessLevelSourceID], [DataSource], [Valid Till Date], [Comments]);


GO
CREATE NONCLUSTERED INDEX [CTSDBAIndex6]
    ON [AVL].[UserRoleMapping]([EmployeeID] ASC, [IsActive] ASC)
    INCLUDE([RoleID], [AccessLevelSourceID], [AccessLevelID]);


GO
CREATE NONCLUSTERED INDEX [IDX_Isactive]
    ON [AVL].[UserRoleMapping]([IsActive] ASC)
    INCLUDE([EmployeeID], [RoleID], [AccessLevelID]);


GO
CREATE NONCLUSTERED INDEX [IDX_Accessid_Isactive]
    ON [AVL].[UserRoleMapping]([AccessLevelID] ASC, [IsActive] ASC)
    INCLUDE([EmployeeID], [RoleID]);


GO
CREATE NONCLUSTERED INDEX [IDX_EmpID_RoleID_AccLevSvcID_AccLevID]
    ON [AVL].[UserRoleMapping]([IsActive] ASC, [DataSource] ASC)
    INCLUDE([EmployeeID], [RoleID], [AccessLevelSourceID], [AccessLevelID]);


GO
CREATE NONCLUSTERED INDEX [IDX_EmployeeID_DataSource]
    ON [AVL].[UserRoleMapping]([IsActive] ASC)
    INCLUDE([EmployeeID], [DataSource]);

