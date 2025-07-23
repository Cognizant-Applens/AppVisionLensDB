CREATE TABLE [AVL].[InfraClusterDefinition] (
    [ID]                       BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerID]               BIGINT        NOT NULL,
    [HierarchyOneDefinition]   NVARCHAR (50) NOT NULL,
    [HierarchyTwoDefinition]   NVARCHAR (50) NOT NULL,
    [HierarchyThreeDefinition] NVARCHAR (50) NOT NULL,
    [HierarchyFourDefinition]  NVARCHAR (50) NULL,
    [HierarchyFiveDefinition]  NVARCHAR (50) NULL,
    [HierarchySixDefinition]   NVARCHAR (50) NULL,
    [IsDeleted]                BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]                NVARCHAR (50) NOT NULL,
    [CreatedDate]              DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]               NVARCHAR (50) NULL,
    [ModifiedDate]             DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InfraClusterDefinition_HierarchyFiveDefinition]
    ON [AVL].[InfraClusterDefinition]([HierarchyFiveDefinition] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_InfraClusterDefinition_HierarchyFourDefinition]
    ON [AVL].[InfraClusterDefinition]([HierarchyFourDefinition] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_InfraClusterDefinition_HierarchyOneDefinition]
    ON [AVL].[InfraClusterDefinition]([HierarchyOneDefinition] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_InfraClusterDefinition_HierarchySixDefinition]
    ON [AVL].[InfraClusterDefinition]([HierarchySixDefinition] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_InfraClusterDefinition_HierarchyThreeDefinition]
    ON [AVL].[InfraClusterDefinition]([HierarchyThreeDefinition] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_InfraClusterDefinition_HierarchyTwoDefinition]
    ON [AVL].[InfraClusterDefinition]([HierarchyTwoDefinition] ASC);

