CREATE TYPE [AVL].[TVP_InfraTowerDetailsTransaction] AS TABLE (
    [InfraTowerTransactionID] BIGINT         NULL,
    [CustomerID]              BIGINT         NOT NULL,
    [InfraTransMappingID]     BIGINT         NOT NULL,
    [TowerName]               NVARCHAR (200) NULL,
    [ModeID]                  INT            NOT NULL,
    [CreatedBy]               NVARCHAR (50)  NULL);

