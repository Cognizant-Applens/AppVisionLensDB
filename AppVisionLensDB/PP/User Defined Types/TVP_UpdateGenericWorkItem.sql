CREATE TYPE [PP].[TVP_UpdateGenericWorkItem] AS TABLE (
    [ProjectId]          BIGINT NOT NULL,
    [ExecutionId]        BIGINT NOT NULL,
    [WorkItemTypeId]     BIGINT NOT NULL,
    [ParentHierarchyId]  BIGINT NOT NULL,
    [IsParentMandate]    INT    NOT NULL,
    [IsEffortTracking]   INT    NOT NULL,
    [IsEstimationPoints] INT    NOT NULL);

