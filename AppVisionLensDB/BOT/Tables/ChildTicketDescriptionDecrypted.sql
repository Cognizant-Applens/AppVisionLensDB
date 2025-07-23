CREATE TABLE [BOT].[ChildTicketDescriptionDecrypted] (
    [Id]                         BIGINT         IDENTITY (1, 1) NOT NULL,
    [JobId]                      NVARCHAR (50)  NOT NULL,
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
    [ModifiedDate]               DATETIME       NULL,
    [CreatedBySystem]            NVARCHAR (50)  NOT NULL,
    [CreatedDateSystem]          DATETIME       NOT NULL,
    [ModifiedBySystem]           NVARCHAR (50)  NULL,
    [ModifiedDateSystem]         DATETIME       NULL,
    CONSTRAINT [PK_ChildTicketDescriptionDecrypted] PRIMARY KEY CLUSTERED ([Id] ASC)
);

