CREATE TYPE [AVL].[TVP_KEDB_TicketSearchFilters] AS TABLE (
    [ProjectId]   NVARCHAR (MAX) NULL,
    [UserId]      NVARCHAR (50)  NULL,
    [DateFrom]    DATETIME       NULL,
    [DateTo]      DATETIME       NULL,
    [Status]      NVARCHAR (MAX) NULL,
    [Application] NVARCHAR (MAX) NULL,
    [Service]     NVARCHAR (MAX) NULL,
    [Priority]    NVARCHAR (MAX) NULL,
    [KAAvailable] VARCHAR (10)   NULL);

