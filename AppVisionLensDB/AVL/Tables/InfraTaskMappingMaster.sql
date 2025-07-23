CREATE TABLE [AVL].[InfraTaskMappingMaster] (
    [InfraMasterTaskMappingID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [TechnologyTowerID]        BIGINT        NOT NULL,
    [SupportLevelID]           INT           NOT NULL,
    [InfraTaskID]              INT           NOT NULL,
    [IsDeleted]                BIT           NULL,
    [CreatedBy]                NVARCHAR (50) NULL,
    [CreatedDate]              DATETIME      NULL,
    [ModifiedBy]               NVARCHAR (50) NULL,
    [ModifiedDate]             DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraMasterTaskMappingID] ASC)
);

