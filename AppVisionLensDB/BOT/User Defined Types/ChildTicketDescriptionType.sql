CREATE TYPE [BOT].[ChildTicketDescriptionType] AS TABLE (
    [TimeTickerID]               BIGINT         NOT NULL,
    [HealingTicketID]            NVARCHAR (50)  NOT NULL,
    [DARTTicketID]               NVARCHAR (50)  NOT NULL,
    [ApplicationID]              BIGINT         NOT NULL,
    [ProjectID]                  BIGINT         NULL,
    [AssignedTo]                 NVARCHAR (100) NULL,
    [TicketDescriptionEncrypted] NVARCHAR (MAX) NOT NULL,
    [TicketDescriptionDecrypted] NVARCHAR (MAX) NOT NULL,
    [CreatedBy]                  NVARCHAR (50)  NOT NULL,
    [CreatedDate]                DATETIME       NOT NULL,
    [ModifiedBy]                 NVARCHAR (50)  NULL,
    [ModifiedDate]               DATETIME       NULL);

