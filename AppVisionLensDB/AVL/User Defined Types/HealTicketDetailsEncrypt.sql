CREATE TYPE [AVL].[HealTicketDetailsEncrypt] AS TABLE (
    [Id]                        BIGINT         NOT NULL,
    [ProjectPatternMapID]       INT            NOT NULL,
    [HealingTicketID]           NVARCHAR (50)  NOT NULL,
    [TicketDescription]         NVARCHAR (MAX) NOT NULL,
    [TicketDescriptionEncrpted] NVARCHAR (MAX) NOT NULL);

