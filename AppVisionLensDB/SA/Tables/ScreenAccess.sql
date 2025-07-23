CREATE TABLE [SA].[ScreenAccess] (
    [ScreenAccessId] INT            IDENTITY (1, 1) NOT NULL,
    [ScreenmasterId] INT            DEFAULT (NULL) NULL,
    [RolesmasterId]  INT            DEFAULT (NULL) NULL,
    [HierarchyId]    INT            DEFAULT (NULL) NULL,
    [Isactive]       BIT            DEFAULT (NULL) NULL,
    [CreatedOn]      DATETIME       DEFAULT (NULL) NULL,
    [CreatedBy]      NVARCHAR (255) DEFAULT (NULL) NULL,
    [ModifiedOn]     DATETIME       DEFAULT (NULL) NULL,
    [ModifiedBy]     NVARCHAR (255) DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([ScreenAccessId] ASC)
);

