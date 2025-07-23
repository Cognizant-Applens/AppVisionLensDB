CREATE TYPE [AVL].[TVP_KEDB_KASearchFilters] AS TABLE (
    [AppID]          NVARCHAR (MAX) NULL,
    [ProjectID]      BIGINT         NULL,
    [Status]         NVARCHAR (MAX) NULL,
    [Service]        NVARCHAR (MAX) NULL,
    [CauseCode]      NVARCHAR (MAX) NULL,
    [ResolutionCode] NVARCHAR (MAX) NULL,
    [PageNumber]     INT            NULL,
    [RowspPage]      INT            NULL,
    [isCognizant]    BIT            NULL);

