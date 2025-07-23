CREATE TABLE [RLE].[AssociateRoleMapping] (
    [AssociateRoleMappingId] INT          IDENTITY (1, 1) NOT NULL,
    [AssociateTypeId]        INT          NULL,
    [ApplensRoleID]          INT          NULL,
    [Isdeleted]              BIT          DEFAULT ((0)) NULL,
    [CreatedBy]              VARCHAR (50) NULL,
    [CreatedDate]            DATETIME     NULL,
    [ModifiedBy]             VARCHAR (50) NULL,
    [ModifiedDate]           DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([AssociateRoleMappingId] ASC),
    FOREIGN KEY ([ApplensRoleID]) REFERENCES [MAS].[RLE_Roles] ([ApplensRoleID]),
    CONSTRAINT [FK_AssociateRoleMapping_Type_Id] FOREIGN KEY ([AssociateTypeId]) REFERENCES [MAS].[AssociateType] ([Id])
);

