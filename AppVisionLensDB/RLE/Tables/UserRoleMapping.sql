CREATE TABLE [RLE].[UserRoleMapping] (
    [RoleMappingID]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [AssociateID]      NVARCHAR (50)   NOT NULL,
    [GroupId]          INT             NOT NULL,
    [ApplensRoleID]    INT             NOT NULL,
    [QualifierComboID] INT             NULL,
    [ValidTillDate]    DATE            NULL,
    [DataSource]       NVARCHAR (50)   NOT NULL,
    [Comments]         NVARCHAR (1000) NULL,
    [IsDeleted]        BIT             CONSTRAINT [DF_UserRoleMapping_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]        NVARCHAR (50)   NOT NULL,
    [CreatedDate]      DATETIME        NOT NULL,
    [ModifiedBy]       NVARCHAR (50)   NULL,
    [ModifiedDate]     DATETIME        NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_UserRoleMapping1] PRIMARY KEY NONCLUSTERED ([RoleMappingID] ASC) ON [PRIMARY],
    CONSTRAINT [FK_UserRoleMapping_RHMSRoleQualifierCombinations] FOREIGN KEY ([QualifierComboID]) REFERENCES [RLE].[RHMSRoleQualifierCombinations] ([QualifierComboID]),
    CONSTRAINT [FK_UserRoleMapping_RLE_Groups] FOREIGN KEY ([GroupId]) REFERENCES [MAS].[RLE_Groups] ([GroupID]),
    CONSTRAINT [FK_UserRoleMapping_RLE_Roles] FOREIGN KEY ([ApplensRoleID]) REFERENCES [MAS].[RLE_Roles] ([ApplensRoleID])
) ON [PartitionShmeAssociateID] ([AssociateID]);


GO
CREATE CLUSTERED INDEX [CIDX_AssociateID]
    ON [RLE].[UserRoleMapping]([AssociateID] ASC)
    ON [PartitionShmeAssociateID] ([AssociateID]);


GO
CREATE NONCLUSTERED INDEX [IDX_UserRoleMapping]
    ON [RLE].[UserRoleMapping]([AssociateID] ASC, [GroupId] ASC, [QualifierComboID] ASC, [IsDeleted] ASC)
    ON [PRIMARY];

