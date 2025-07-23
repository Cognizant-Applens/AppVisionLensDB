CREATE TYPE [PP].[FieldProjectMapping] AS TABLE (
    [MappingId]       BIGINT         NULL,
    [ProjectId]       BIGINT         NULL,
    [StandardFieldId] BIGINT         NULL,
    [SourceName]      NVARCHAR (400) NULL,
    [IsChecked]       BIT            NULL,
    [IsEffort]        BIT            NULL);

