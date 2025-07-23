CREATE TYPE [dbo].[TVP_MLOptionalWordList] AS TABLE (
    [OptionalFieldNoiseWord] NVARCHAR (500) NULL,
    [Frequency]              BIGINT         NULL,
    [IsActive]               BIT            NULL,
    [IsDeleted]              BIT            NULL);

