CREATE TABLE [RLE].[UserRoleFieldConfigs] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [ApplensRoleId] INT           NOT NULL,
    [GroupID]       INT           NOT NULL,
    [FieldName]     NVARCHAR (50) NULL,
    [IsMandatory]   BIT           CONSTRAINT [DF_UserRoleFieldConfigs_Mandatory] DEFAULT ((0)) NOT NULL,
    [AllowOnlyRole] BIT           CONSTRAINT [DF_UserRoleFieldConfigs_OnlyRole] DEFAULT ((0)) NOT NULL,
    [IsAccssLevel]  BIT           CONSTRAINT [DF_UserRoleFieldConfigs_IsAccsslevel] DEFAULT ((0)) NOT NULL,
    [IsDeleted]     BIT           CONSTRAINT [DF_UserRoleFieldConfigs_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     NVARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME      NOT NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    CONSTRAINT [PK_UserRoleFieldConfigs] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UserRoleFieldConfigs_RLE_Groups] FOREIGN KEY ([GroupID]) REFERENCES [MAS].[RLE_Groups] ([GroupID]),
    CONSTRAINT [FK_UserRoleFieldConfigs_RLE_Roles] FOREIGN KEY ([ApplensRoleId]) REFERENCES [MAS].[RLE_Roles] ([ApplensRoleID])
);

