CREATE TYPE [AVL].[TVP_ProjectMappingInfraParam] AS TABLE (
    [TowerID]    BIGINT        NOT NULL,
    [IsEnabled]  BIT           NULL,
    [ProjectID]  BIGINT        NOT NULL,
    [UserID]     NVARCHAR (50) NULL,
    [CustomerID] BIGINT        NOT NULL);

