CREATE TABLE [RLE].[LP_RoleModuleMapping] (
    [RoleModuleMappingId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ApplensRoleID]       INT           NULL,
    [ModuleId]            BIGINT        NULL,
    [IsDeleted]           BIT           NOT NULL,
    [CreatedBy]           NVARCHAR (50) NOT NULL,
    [CreatedDate]         DATETIME      NOT NULL,
    [ModifiedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([RoleModuleMappingId] ASC),
    FOREIGN KEY ([ApplensRoleID]) REFERENCES [MAS].[RLE_Roles] ([ApplensRoleID]),
    FOREIGN KEY ([ModuleId]) REFERENCES [MAS].[ApplensModules] ([ModuleId])
);

