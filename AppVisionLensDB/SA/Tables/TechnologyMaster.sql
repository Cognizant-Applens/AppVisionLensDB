CREATE TABLE [SA].[TechnologyMaster] (
    [TechnologyId]   INT            NOT NULL,
    [TechnologyName] NVARCHAR (500) DEFAULT (NULL) NULL,
    [IsDeleted]      NVARCHAR (10)  DEFAULT (NULL) NULL,
    [CreatedBy]      NVARCHAR (10)  DEFAULT (NULL) NULL,
    [CreatedOn]      DATETIME       DEFAULT (NULL) NULL,
    [ModifiedBy]     NVARCHAR (10)  DEFAULT (NULL) NULL,
    [ModifiedDate]   DATETIME       DEFAULT (NULL) NULL
);

