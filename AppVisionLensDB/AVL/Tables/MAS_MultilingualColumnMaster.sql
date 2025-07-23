CREATE TABLE [AVL].[MAS_MultilingualColumnMaster] (
    [ColumnID]     INT            IDENTITY (1, 1) NOT NULL,
    [ColumnName]   NVARCHAR (100) NULL,
    [IsActive]     BIT            NULL,
    [CreatedBy]    NVARCHAR (10)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (10)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ColumnID] ASC)
);

