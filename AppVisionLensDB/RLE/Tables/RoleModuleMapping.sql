CREATE TABLE [RLE].[RoleModuleMapping] (
    [MappingId]              INT          IDENTITY (1, 1) NOT NULL,
    [AssociateRoleMappingId] INT          NULL,
    [ModuleId]               INT          NULL,
    [Isdeleted]              BIT          DEFAULT ((0)) NULL,
    [CreatedBy]              VARCHAR (50) NULL,
    [CreatedDate]            DATETIME     NULL,
    [ModifiedBy]             VARCHAR (50) NULL,
    [ModifiedDate]           DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([MappingId] ASC),
    FOREIGN KEY ([AssociateRoleMappingId]) REFERENCES [RLE].[AssociateRoleMapping] ([AssociateRoleMappingId]),
    CONSTRAINT [FK_RoleModuleMapping_ModuleId] FOREIGN KEY ([ModuleId]) REFERENCES [MAS].[Modules] ([ModuleId])
);

