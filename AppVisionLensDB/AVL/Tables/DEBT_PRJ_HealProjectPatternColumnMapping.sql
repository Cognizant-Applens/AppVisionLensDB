CREATE TABLE [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (
    [ProjectPatternColumnMapID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]                 INT           NOT NULL,
    [ColumnID]                  INT           NOT NULL,
    [IsActive]                  BIT           NULL,
    [CreatedBy]                 NVARCHAR (10) NULL,
    [CreatedDate]               DATETIME      NULL,
    [ModifiedBy]                NVARCHAR (10) NULL,
    [ModifiedDate]              DATETIME      NULL
);

