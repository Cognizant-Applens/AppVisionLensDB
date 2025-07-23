CREATE TYPE [ML].[TVP_NoiseAdditionTags] AS TABLE (
    [SupportType]            VARCHAR (2)    NULL,
    [ApplicationID]          BIGINT         NULL,
    [ApplicationName]        NVARCHAR (100) NULL,
    [TowerId]                BIGINT         NULL,
    [TowerName]              NVARCHAR (100) NULL,
    [NoiseWords]             NVARCHAR (500) NULL,
    [IsActive]               BIT            NULL,
    [Frequency]              BIGINT         NULL,
    [OptionalFieldNoiseWord] NVARCHAR (500) NULL,
    [OptionalFieldFrequency] INT            NULL,
    [IsActiveResolution]     BIT            NULL);

