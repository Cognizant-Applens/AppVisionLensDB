CREATE TABLE [AVL].[InfraMasterTowerDetails] (
    [InfraMasterTowerID]   INT           IDENTITY (1, 1) NOT NULL,
    [InfraMasterMappingID] INT           NOT NULL,
    [TowerName]            NVARCHAR (50) NULL,
    [IsDeleted]            BIT           NULL,
    [CreatedBy]            NVARCHAR (50) NULL,
    [CreatedDate]          DATETIME      NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraMasterTowerID] ASC)
);

