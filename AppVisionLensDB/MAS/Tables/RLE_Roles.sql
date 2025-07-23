CREATE TABLE [MAS].[RLE_Roles] (
    [ApplensRoleID] INT            IDENTITY (1, 1) NOT NULL,
    [RoleName]      NVARCHAR (200) NOT NULL,
    [RoleKey]       NVARCHAR (6)   NOT NULL,
    [IsDeleted]     BIT            CONSTRAINT [DF_RLE_Roles_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    [IsUIEnable]    BIT            CONSTRAINT [DF__RLE_Roles__IsUIEnable] DEFAULT ((1)) NULL,
    [Priority]      INT            NULL,
    CONSTRAINT [PK_RLE_Roles] PRIMARY KEY CLUSTERED ([ApplensRoleID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_RLE_Roles]
    ON [MAS].[RLE_Roles]([RoleName] ASC, [ApplensRoleID] ASC, [IsDeleted] ASC);

