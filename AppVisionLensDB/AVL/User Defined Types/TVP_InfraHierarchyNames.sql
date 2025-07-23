CREATE TYPE [AVL].[TVP_InfraHierarchyNames] AS TABLE (
    [CustomerID]    BIGINT         NOT NULL,
    [Mode]          INT            NULL,
    [HierarchyName] NVARCHAR (MAX) NULL,
    [CreatedBy]     NVARCHAR (50)  NULL);

