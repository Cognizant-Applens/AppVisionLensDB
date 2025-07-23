CREATE TYPE [AVL].[TVP_InfraSaveTaskMappingDetails] AS TABLE (
    [InfraTaskID]            BIGINT          NULL,
    [TechnologyTowerID]      BIGINT          NULL,
    [TechnologyTower]        NVARCHAR (100)  NULL,
    [ServiceLevelID]         BIGINT          NULL,
    [ServiceLevelName]       NVARCHAR (50)   NULL,
    [InfraTransactionTaskID] INT             NULL,
    [InfraTaskName]          NVARCHAR (2000) NULL,
    [IsEnabled]              BIT             NULL,
    [IsMaster]               BIT             NULL);

