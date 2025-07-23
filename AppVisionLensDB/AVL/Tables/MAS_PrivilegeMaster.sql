CREATE TABLE [AVL].[MAS_PrivilegeMaster] (
    [PrivilegeID] INT            IDENTITY (1, 1) NOT NULL,
    [MenuName]    NVARCHAR (MAX) NULL,
    [IconName]    NVARCHAR (MAX) NULL,
    [IsDeleted]   BIT            NULL,
    [CreatedBy]   NVARCHAR (MAX) NULL,
    [ModifiedBy]  NVARCHAR (MAX) NULL,
    [DisplayName] NVARCHAR (100) NULL,
    [IsDefault]   BIT            CONSTRAINT [DF_MAS_PrivilegeMaster] DEFAULT ((10)) NOT NULL
);

