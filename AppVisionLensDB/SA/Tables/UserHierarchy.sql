CREATE TABLE [SA].[UserHierarchy] (
    [UserHierarchyID] INT            IDENTITY (1, 1) NOT NULL,
    [HierarchyName]   NVARCHAR (150) DEFAULT (NULL) NULL,
    [IsDeleted]       NVARCHAR (50)  DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([UserHierarchyID] ASC)
);

