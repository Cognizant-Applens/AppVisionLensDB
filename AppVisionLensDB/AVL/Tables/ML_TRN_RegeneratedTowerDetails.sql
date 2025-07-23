CREATE TABLE [AVL].[ML_TRN_RegeneratedTowerDetails] (
    [ID]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [InitialLearningID] BIGINT        NULL,
    [CustomerID]        BIGINT        NOT NULL,
    [ProjectID]         BIGINT        NOT NULL,
    [HierarchyOneId]    BIGINT        NULL,
    [HierarchyTwoId]    BIGINT        NULL,
    [HierarchyThreeId]  BIGINT        NULL,
    [TowerID]           BIGINT        NULL,
    [IsMLSignOff]       INT           DEFAULT ((0)) NULL,
    [FromDate]          DATE          NULL,
    [ToDate]            DATE          NULL,
    [IsDeleted]         BIT           NULL,
    [CreatedBy]         NVARCHAR (50) NULL,
    [CreatedDate]       DATETIME      NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

