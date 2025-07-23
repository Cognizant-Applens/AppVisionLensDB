CREATE TABLE [AVL].[AppInfraTicketsSyncUpStatus] (
    [ID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [StartTime]    DATETIME      NULL,
    [EndTime]      DATETIME      NULL,
    [IsProcessed]  BIT           NULL,
    [IsDeleted]    BIT           NULL,
    [CreatedDate]  DATETIME      NULL,
    [CreatedBy]    NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

