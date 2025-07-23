CREATE TYPE [AVL].[TVP_KEDB_SaveKA_ActivityDetails] AS TABLE (
    [KAActivityID]        BIGINT          NULL,
    [KAId]                BIGINT          NULL,
    [ActivityDescription] NVARCHAR (4000) NULL,
    [Effort]              NVARCHAR (50)   NULL,
    [IsAutomatable]       BIT             NULL);

