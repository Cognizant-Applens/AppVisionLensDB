CREATE TABLE [AVL].[InfraTowerDetailsTransaction] (
    [InfraTowerTransactionID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerID]              BIGINT         NOT NULL,
    [InfraTransMappingID]     BIGINT         NOT NULL,
    [TowerName]               NVARCHAR (200) NULL,
    [ModeID]                  INT            NOT NULL,
    [IsDeleted]               BIT            NULL,
    [CreatedBy]               NVARCHAR (50)  NULL,
    [CreatedDate]             DATETIME       NULL,
    [ModifiedBy]              NVARCHAR (50)  NULL,
    [ModifiedDate]            DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([InfraTowerTransactionID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InfraTowerDetailsTransaction_InfraTransMappingID_IsDeleted_InfraTowerTransactionID]
    ON [AVL].[InfraTowerDetailsTransaction]([InfraTransMappingID] ASC, [IsDeleted] ASC, [InfraTowerTransactionID] ASC)
    INCLUDE([TowerName]);

