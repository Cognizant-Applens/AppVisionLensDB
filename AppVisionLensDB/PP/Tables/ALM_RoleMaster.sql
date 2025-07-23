CREATE TABLE [PP].[ALM_RoleMaster] (
    [RoleID]       INT            IDENTITY (1, 1) NOT NULL,
    [RoleName]     NVARCHAR (100) NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([RoleID] ASC)
);

