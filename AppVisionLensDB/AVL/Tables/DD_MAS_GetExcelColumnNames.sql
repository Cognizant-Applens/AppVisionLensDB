CREATE TABLE [AVL].[DD_MAS_GetExcelColumnNames] (
    [ColID]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ColumnName] NVARCHAR (100) NOT NULL,
    [IsDeleted]  BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ColID] ASC)
);

