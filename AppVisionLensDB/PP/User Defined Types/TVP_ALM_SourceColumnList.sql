CREATE TYPE [PP].[TVP_ALM_SourceColumnList] AS TABLE (
    [ProjectID]   INT           NULL,
    [ColumnName]  VARCHAR (100) NULL,
    [IsDeleted]   INT           NULL,
    [CreatedBy]   VARCHAR (100) NULL,
    [CreatedDate] DATETIME      NULL);

