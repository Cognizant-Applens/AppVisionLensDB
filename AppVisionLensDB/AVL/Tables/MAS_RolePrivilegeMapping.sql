CREATE TABLE [AVL].[MAS_RolePrivilegeMapping] (
    [RolePrvMapID] INT            IDENTITY (1, 1) NOT NULL,
    [RoleID]       INT            NULL,
    [PrivilegeID]  INT            NULL,
    [IsDeleted]    BIT            NULL,
    [CreatedBy]    NVARCHAR (MAX) NULL,
    [ModifiedBy]   NVARCHAR (MAX) NULL
);

