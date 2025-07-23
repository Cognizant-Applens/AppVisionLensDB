CREATE TABLE [AVL].[InfraTaskMappingTransaction] (
    [InfraTaskID]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerID]               BIGINT        NOT NULL,
    [InfraMasterTaskMappingID] BIGINT        NULL,
    [TechnologyTowerID]        BIGINT        NOT NULL,
    [SupportLevelID]           INT           NOT NULL,
    [InfraTransactionTaskID]   BIGINT        NOT NULL,
    [IsMaster]                 BIT           NULL,
    [IsEnabled]                BIT           NULL,
    [IsDeleted]                BIT           NULL,
    [CreatedBy]                NVARCHAR (50) NULL,
    [CreatedDate]              DATETIME      NULL,
    [ModifiedBy]               NVARCHAR (50) NULL,
    [ModifiedDate]             DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraTaskID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NCI_InfraTaskMappingTransaction_CustomerID_IsEnabled]
    ON [AVL].[InfraTaskMappingTransaction]([CustomerID] ASC, [IsEnabled] ASC)
    INCLUDE([TechnologyTowerID], [SupportLevelID], [InfraTransactionTaskID]);


GO
CREATE NONCLUSTERED INDEX [NCI_InfraTaskMappingTransaction_CustomerID_TechnologyTowerID_IsEnabled]
    ON [AVL].[InfraTaskMappingTransaction]([CustomerID] ASC, [TechnologyTowerID] ASC, [IsEnabled] ASC)
    INCLUDE([SupportLevelID], [InfraTransactionTaskID]);

