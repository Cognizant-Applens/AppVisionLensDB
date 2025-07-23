CREATE TYPE [AVL].[TicketDetailsEncrypt] AS TABLE (
    [TimeTickerID]              BIGINT         NOT NULL,
    [TicketID]                  NVARCHAR (50)  NOT NULL,
    [ApplicationID]             BIGINT         NOT NULL,
    [ProjectID]                 BIGINT         NOT NULL,
    [TicketDescription]         NVARCHAR (MAX) NOT NULL,
    [TicketDescriptionEncrpted] NVARCHAR (MAX) NOT NULL,
    [TicketSummmary]            NVARCHAR (MAX) NULL,
    [TicketSummaryEncrypted]    NVARCHAR (MAX) NULL);

