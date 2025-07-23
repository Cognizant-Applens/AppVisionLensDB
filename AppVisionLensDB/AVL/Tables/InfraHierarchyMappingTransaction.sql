CREATE TABLE [AVL].[InfraHierarchyMappingTransaction] (
    [InfraTransMappingID]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerID]                  BIGINT        NOT NULL,
    [InfraMasterMappingID]        INT           NULL,
    [HierarchyOneTransactionID]   BIGINT        NOT NULL,
    [HierarchyTwoTransactionID]   BIGINT        NOT NULL,
    [HierarchyThreeTransactionID] BIGINT        NOT NULL,
    [HierarchyFourTransactionID]  BIGINT        NULL,
    [HierarchyFiveTransactionID]  BIGINT        NULL,
    [HierarchySixTransactionID]   BIGINT        NULL,
    [IsMaster]                    BIT           NULL,
    [IsDeleted]                   BIT           NULL,
    [CreatedBy]                   NVARCHAR (50) NULL,
    [CreatedDate]                 DATETIME      NULL,
    [ModifiedBy]                  NVARCHAR (50) NULL,
    [ModifiedDate]                DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraTransMappingID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InfraHierarchyMappingTransaction_InfraTransMappingID_CustomerID_HierarchyTransactionID]
    ON [AVL].[InfraHierarchyMappingTransaction]([InfraTransMappingID] ASC, [CustomerID] ASC, [HierarchyOneTransactionID] ASC, [HierarchyTwoTransactionID] ASC, [HierarchyThreeTransactionID] ASC, [HierarchyFourTransactionID] ASC, [HierarchyFiveTransactionID] ASC, [HierarchySixTransactionID] ASC);

