CREATE TYPE [dbo].[InsertUpdateMaster] AS TABLE (
    [TableName]   NVARCHAR (100) NULL,
    [ColumnId]    NVARCHAR (30)  NULL,
    [ColumnName]  NVARCHAR (100) NULL,
    [ColumnValue] NVARCHAR (100) NULL);

