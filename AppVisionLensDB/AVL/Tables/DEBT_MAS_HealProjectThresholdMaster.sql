CREATE TABLE [AVL].[DEBT_MAS_HealProjectThresholdMaster] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [ProjectID]      INT           NULL,
    [ThresholdCount] INT           NULL,
    [CreatedBy]      NVARCHAR (50) NULL,
    [CreatedDate]    DATE          NULL,
    [ModifiedBy]     NVARCHAR (50) NULL,
    [ModifiedDate]   DATE          NULL,
    [IsDeleted]      BIT           NULL
);

