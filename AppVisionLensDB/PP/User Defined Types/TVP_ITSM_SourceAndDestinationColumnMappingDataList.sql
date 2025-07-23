CREATE TYPE [PP].[TVP_ITSM_SourceAndDestinationColumnMappingDataList] AS TABLE (
    [ProjectID]        BIGINT        NOT NULL,
    [SourceColumnName] BIGINT        NOT NULL,
    [MappedColumnName] VARCHAR (100) NOT NULL,
    [SOURCEINDEX]      INT           NULL,
    [DESTINATIONINDEX] INT           NULL,
    [IsDeleted]        BIT           NULL,
    [CreatedBy]        VARCHAR (100) NULL,
    [CreatedDate]      DATETIME      NULL);

