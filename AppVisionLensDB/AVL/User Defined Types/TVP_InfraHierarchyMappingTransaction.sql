CREATE TYPE [AVL].[TVP_InfraHierarchyMappingTransaction] AS TABLE (
    [InfraTransMappingID]         BIGINT        NULL,
    [CustomerID]                  BIGINT        NOT NULL,
    [InfraMasterMappingID]        BIGINT        NULL,
    [HierarchyOneTransactionID]   BIGINT        NOT NULL,
    [HierarchyTwoTransactionID]   BIGINT        NOT NULL,
    [HierarchyThreeTransactionID] BIGINT        NOT NULL,
    [HierarchyFourTransactionID]  BIGINT        NULL,
    [HierarchyFiveTransactionID]  BIGINT        NULL,
    [HierarchySixTransactionID]   BIGINT        NULL,
    [IsMaster]                    BIT           NULL,
    [CreatedBy]                   NVARCHAR (50) NULL);

