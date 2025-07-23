CREATE TYPE [AVL].[TVP_KEDB_ResolutionWorkbenchFilters] AS TABLE (
    [AccountId]                 BIGINT         NULL,
    [ProjectId]                 VARCHAR (MAX)  NULL,
    [TicketId]                  VARCHAR (100)  NULL,
    [TicketDescription]         NVARCHAR (MAX) NULL,
    [SearchKey]                 VARCHAR (120)  NULL,
    [AllSelectEnable]           BIT            NULL,
    [KATitleEnable]             BIT            NULL,
    [KADescriptionEnable]       BIT            NULL,
    [ActivityDescriptionEnable] BIT            NULL,
    [KeyWordEnable]             BIT            NULL,
    [CauseCodeEnable]           BIT            NULL,
    [ResolutionCodeEnable]      BIT            NULL);

