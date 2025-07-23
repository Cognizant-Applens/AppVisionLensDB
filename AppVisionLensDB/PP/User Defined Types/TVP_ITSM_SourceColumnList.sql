CREATE TYPE [PP].[TVP_ITSM_SourceColumnList] AS TABLE (
    [ProjectID]         INT           NULL,
    [ServiceDartColumn] VARCHAR (100) NULL,
    [ProjectColumn]     VARCHAR (100) NULL,
    [IsDeleted]         INT           NULL,
    [CreatedBy]         VARCHAR (100) NULL,
    [CreatedDate]       DATETIME      NULL);

