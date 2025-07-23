CREATE TABLE [SA].[RolesMaster] (
    [RoleId]     INT            IDENTITY (1, 1) NOT NULL,
    [RoleName]   NVARCHAR (255) NULL,
    [CreatedBy]  NVARCHAR (10)  NULL,
    [CreatedOn]  DATETIME       NULL,
    [ModifiedBy] NVARCHAR (10)  NULL,
    [ModifiedOn] DATETIME       NULL,
    [IsActive]   BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([RoleId] ASC) WITH (FILLFACTOR = 80)
);

