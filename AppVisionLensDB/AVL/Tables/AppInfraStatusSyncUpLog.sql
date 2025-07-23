CREATE TABLE [AVL].[AppInfraStatusSyncUpLog] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [JobID]         BIGINT         NULL,
    [TimeTickerID]  BIGINT         NOT NULL,
    [SupportTypeID] INT            NULL,
    [ProjectID]     BIGINT         NULL,
    [TicketID]      NVARCHAR (100) NULL,
    [CreatedDate]   DATETIME       NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

