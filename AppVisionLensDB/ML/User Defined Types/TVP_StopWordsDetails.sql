CREATE TYPE [ML].[TVP_StopWordsDetails] AS TABLE (
    [ApplicationID]   BIGINT         NULL,
    [ApplicationName] NVARCHAR (100) NULL,
    [TowerId]         BIGINT         NULL,
    [TowerName]       NVARCHAR (100) NULL,
    [StopWords]       NVARCHAR (500) NULL,
    [IsActive]        BIT            NULL,
    [Frequency]       BIGINT         NULL,
    [StopWordKey]     NVARCHAR (20)  NULL);

