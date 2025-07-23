CREATE TABLE [AVL].[TK_MAP_ProjectStatusMapping] (
    [StatusID]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [StatusName]            VARCHAR (500) NULL,
    [TicketStatus_ID]       BIGINT        NULL,
    [ProjectID]             BIGINT        NOT NULL,
    [IsDeleted]             BIT           NULL,
    [CreatedDate]           DATETIME      NULL,
    [CreatedBy]             NVARCHAR (50) NULL,
    [ModifiedDate]          DATETIME      NULL,
    [ModifiedBy]            NVARCHAR (50) NULL,
    [IsDefaultTicketStatus] NVARCHAR (50) CONSTRAINT [DF__PRJ_Statu__IsDef__66EA454A] DEFAULT ('N') NULL,
    CONSTRAINT [pk_Status] PRIMARY KEY CLUSTERED ([StatusID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_TK_MAP_ProjectStatusMapping_TK_MAS_DARTTicketStatus] FOREIGN KEY ([TicketStatus_ID]) REFERENCES [AVL].[TK_MAS_DARTTicketStatus] ([DARTStatusID]),
    CONSTRAINT [FK_TK_PRJ_StatusMapping_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_MAP_ProjectStatusMapping_ProjectID]
    ON [AVL].[TK_MAP_ProjectStatusMapping]([ProjectID] ASC)
    INCLUDE([StatusID], [StatusName], [TicketStatus_ID], [IsDeleted]);

