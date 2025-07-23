CREATE TYPE [AVL].[TVP_KEDB_KTicketMap] AS TABLE (
    [KTicketId]  NVARCHAR (50) NULL,
    [ProjectId]  BIGINT        NULL,
    [KATicketID] NVARCHAR (50) NULL,
    [IsMapped]   BIT           NULL,
    [CreatedBy]  NVARCHAR (50) NULL);

