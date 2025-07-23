CREATE TABLE [AVL].[InfraHierarchySixTransaction] (
    [HierarchySixTransactionID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerID]                BIGINT        NOT NULL,
    [HierarchyName]             NVARCHAR (50) NOT NULL,
    [IsDeleted]                 BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]                 NVARCHAR (10) NOT NULL,
    [CreatedDate]               DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]                NVARCHAR (10) NULL,
    [ModifiedDate]              DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([HierarchySixTransactionID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InfraHierarchySixTransaction_HierarchySixTransactionID_IsDeleted]
    ON [AVL].[InfraHierarchySixTransaction]([HierarchySixTransactionID] ASC, [IsDeleted] ASC)
    INCLUDE([HierarchyName]);

