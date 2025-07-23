CREATE TABLE [AVL].[InfraHierarchyFiveTransaction] (
    [HierarchyFiveTransactionID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerID]                 BIGINT        NOT NULL,
    [HierarchyName]              NVARCHAR (50) NOT NULL,
    [IsDeleted]                  BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]                  NVARCHAR (10) NOT NULL,
    [CreatedDate]                DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]                 NVARCHAR (10) NULL,
    [ModifiedDate]               DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([HierarchyFiveTransactionID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InfraHierarchyFiveTransaction_HierarchyFiveTransactionID_IsDeleted]
    ON [AVL].[InfraHierarchyFiveTransaction]([HierarchyFiveTransactionID] ASC, [IsDeleted] ASC)
    INCLUDE([HierarchyName]);

