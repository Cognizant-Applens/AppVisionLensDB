CREATE TABLE [AVL].[InfraMasterHierarchyMapping] (
    [InfraMasterMappingID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [HierarchyOneMasterID]   INT           NOT NULL,
    [HierarchyTwoMasterID]   INT           NOT NULL,
    [HierarchyThreeMasterID] INT           NOT NULL,
    [HierarchyFourMasterID]  INT           NULL,
    [HierarchyFiveMasterID]  INT           NULL,
    [HierarchySixMasterID]   INT           NULL,
    [IsDeleted]              BIT           NULL,
    [CreatedBy]              NVARCHAR (50) NULL,
    [CreatedDate]            DATETIME      NULL,
    [ModifiedBy]             NVARCHAR (50) NULL,
    [ModifiedDate]           DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraMasterMappingID] ASC)
);

