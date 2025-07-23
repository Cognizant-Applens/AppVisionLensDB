CREATE TYPE [ML].[TVP_MLOptionalWordList] AS TABLE (
    [ID]                     BIGINT         NULL,
    [OptionalFieldNoiseWord] NVARCHAR (500) NULL,
    [Frequency]              BIGINT         NULL,
    [IsActive]               BIT            NULL);

