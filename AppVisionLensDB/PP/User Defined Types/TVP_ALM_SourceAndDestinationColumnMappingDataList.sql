CREATE TYPE [PP].[TVP_ALM_SourceAndDestinationColumnMappingDataList] AS TABLE (
    [ProjectID]        BIGINT        NOT NULL,
    [SourceColumnId]   BIGINT        NOT NULL,
    [MappedColumnName] VARCHAR (100) NOT NULL,
    [IsDeleted]        BIT           NULL,
    [CreatedBy]        VARCHAR (100) NULL,
    [CreatedDate]      DATETIME      NULL);

