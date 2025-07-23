CREATE TABLE [PP].[ALM_MAP_GenericWorkItemConfig] (
    [Id]                 BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectId]          BIGINT        NOT NULL,
    [ExecutionId]        INT           NOT NULL,
    [WorkItemTypeId]     BIGINT        NOT NULL,
    [ParentHierarchyId]  BIGINT        NULL,
    [IsParentMandate]    BIT           DEFAULT ((0)) NOT NULL,
    [IsEffortTracking]   BIT           DEFAULT ((0)) NOT NULL,
    [IsEstimationPoints] BIT           DEFAULT ((0)) NOT NULL,
    [IsDeleted]          BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]          NVARCHAR (50) NOT NULL,
    [CreatedDate]        DATETIME      NOT NULL,
    [ModifiedBy]         NVARCHAR (50) NULL,
    [ModifiedDate]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ALM_MAP_GenericWorkItemConfig_ExecutionId] FOREIGN KEY ([ExecutionId]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID]),
    CONSTRAINT [FK_ALM_MAP_GenericWorkItemConfig_ProjectId] FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_ALM_MAP_GenericWorkItemConfig_WorkItemTypeId] FOREIGN KEY ([WorkItemTypeId]) REFERENCES [PP].[ALM_MAS_WorkType] ([WorkTypeId])
);

