CREATE TABLE [SA].[HierarchyConfiguration] (
    [ConfigurationId]          INT           IDENTITY (1, 1) NOT NULL,
    [ConfigurationOrderId]     INT           DEFAULT (NULL) NULL,
    [ConfigurationHierarchyId] NVARCHAR (10) DEFAULT (NULL) NULL,
    [ConfigurationCreatedBy]   NVARCHAR (50) DEFAULT (NULL) NULL,
    [ConfigurationCreatedOn]   DATETIME      DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([ConfigurationId] ASC)
);

