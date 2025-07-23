CREATE TABLE [RLE].[RHMSRoles] (
    [ApplensRHMSRoleID] INT            IDENTITY (1, 1) NOT NULL,
    [RHMSRoleID]        NVARCHAR (50)  NULL,
    [RHMSRoleName]      NVARCHAR (200) NOT NULL,
    [IsDeleted]         BIT            CONSTRAINT [DF_RHMSRoles_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    CONSTRAINT [PK_RHMSRoles] PRIMARY KEY CLUSTERED ([ApplensRHMSRoleID] ASC),
    UNIQUE NONCLUSTERED ([RHMSRoleID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_RHMSRoleName]
    ON [RLE].[RHMSRoles]([RHMSRoleName] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_RHMSRoles]
    ON [RLE].[RHMSRoles]([IsDeleted] ASC, [ApplensRHMSRoleID] ASC);

