CREATE TYPE [AVL].[TVP_KEDB_Rating_TicketMap] AS TABLE (
    [ProjectId]      BIGINT         NULL,
    [KAID]           BIGINT         NULL,
    [TicketId]       NVARCHAR (100) NULL,
    [IsLinked]       BIT            NULL,
    [Rating]         INT            NULL,
    [ReviewComments] VARCHAR (200)  NULL,
    [Improvements]   VARCHAR (250)  NULL,
    [CreatedBy]      NVARCHAR (50)  NULL);

