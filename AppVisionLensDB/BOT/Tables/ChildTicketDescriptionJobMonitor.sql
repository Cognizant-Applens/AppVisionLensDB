CREATE TABLE [BOT].[ChildTicketDescriptionJobMonitor] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [JobId]        NVARCHAR (50) NOT NULL,
    [JobType]      NVARCHAR (50) NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_ChildTicketDescriptionJobMonitor] PRIMARY KEY CLUSTERED ([Id] ASC)
);

