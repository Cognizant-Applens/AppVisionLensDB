CREATE TABLE [AVL].[RoleMaster] (
    [RoleId]       INT            NOT NULL,
    [RoleName]     NVARCHAR (100) NULL,
    [Priority]     INT            NULL,
    [RoleType]     NVARCHAR (100) NULL,
    [IsActive]     BIT            NULL,
    [CreatedDate]  DATETIME       NULL,
    [CreatedBy]    NVARCHAR (255) NULL,
    [ModifiedDate] DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([RoleId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Rn_Isactive]
    ON [AVL].[RoleMaster]([RoleName] ASC, [IsActive] ASC);

