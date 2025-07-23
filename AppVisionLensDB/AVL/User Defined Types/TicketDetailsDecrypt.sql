CREATE TYPE [AVL].[TicketDetailsDecrypt] AS TABLE (
    [TimeTickerID]               BIGINT         NOT NULL,
    [TicketID]                   NVARCHAR (50)  NOT NULL,
    [ApplicationID]              BIGINT         NOT NULL,
    [ProjectID]                  BIGINT         NOT NULL,
    [TicketDescription]          NVARCHAR (MAX) NOT NULL,
    [TicketDescriptionDecrypted] NVARCHAR (MAX) NOT NULL);

