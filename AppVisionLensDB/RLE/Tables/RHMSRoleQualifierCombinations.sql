CREATE TABLE [RLE].[RHMSRoleQualifierCombinations] (
    [QualifierComboID]          INT           IDENTITY (1, 1) NOT NULL,
    [ApplensRHMSRoleID]         INT           NOT NULL,
    [PrimaryPortfolioTypeID]    INT           NULL,
    [PortfolioQualifier1TypeID] INT           NULL,
    [PortfolioQualifier2TypeID] INT           NULL,
    [ApplensRoleID]             INT           NOT NULL,
    [GroupID]                   INT           NOT NULL,
    [IsDeleted]                 BIT           CONSTRAINT [DF_RHMSRoleAccessLevelCompinations_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]                 NVARCHAR (50) NOT NULL,
    [CreatedDate]               DATETIME      NOT NULL,
    [ModifiedBy]                NVARCHAR (50) NULL,
    [ModifiedDate]              DATETIME      NULL,
    CONSTRAINT [PK_RHMSRoleAccessLevelCompinations] PRIMARY KEY CLUSTERED ([QualifierComboID] ASC),
    CONSTRAINT [FK_RHMSRoleQualifierCombinations_RHMSRoles] FOREIGN KEY ([ApplensRHMSRoleID]) REFERENCES [RLE].[RHMSRoles] ([ApplensRHMSRoleID]),
    CONSTRAINT [FK_RHMSRoleQualifierCombinations_RLE_AccessLevelTypes] FOREIGN KEY ([PrimaryPortfolioTypeID]) REFERENCES [MAS].[RLE_AccessLevelTypes] ([AccessLevelTypeID]),
    CONSTRAINT [FK_RHMSRoleQualifierCombinations_RLE_AccessLevelTypes1] FOREIGN KEY ([PortfolioQualifier1TypeID]) REFERENCES [MAS].[RLE_AccessLevelTypes] ([AccessLevelTypeID]),
    CONSTRAINT [FK_RHMSRoleQualifierCombinations_RLE_AccessLevelTypes2] FOREIGN KEY ([PortfolioQualifier2TypeID]) REFERENCES [MAS].[RLE_AccessLevelTypes] ([AccessLevelTypeID]),
    CONSTRAINT [FK_RHMSRoleQualifierCombinations_RLE_Groups] FOREIGN KEY ([GroupID]) REFERENCES [MAS].[RLE_Groups] ([GroupID]),
    CONSTRAINT [FK_RHMSRoleQualifierCombinations_RLE_Roles] FOREIGN KEY ([ApplensRoleID]) REFERENCES [MAS].[RLE_Roles] ([ApplensRoleID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_RHMSRoleQualifierCombinations]
    ON [RLE].[RHMSRoleQualifierCombinations]([ApplensRHMSRoleID] ASC, [ApplensRoleID] ASC, [PrimaryPortfolioTypeID] ASC, [PortfolioQualifier1TypeID] ASC, [PortfolioQualifier2TypeID] ASC, [IsDeleted] ASC);

