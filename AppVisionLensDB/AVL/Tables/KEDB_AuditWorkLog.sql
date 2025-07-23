CREATE TABLE [AVL].[KEDB_AuditWorkLog] (
    [WorkLogId]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [KAID]         BIGINT         NULL,
    [ProjectId]    BIGINT         NULL,
    [Action]       NVARCHAR (50)  NULL,
    [Comments]     NVARCHAR (500) NULL,
    [LogCreatedBy] VARCHAR (50)   NULL,
    [CreatedOn]    DATETIME       DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_KEDB_AuditWorkLog] PRIMARY KEY CLUSTERED ([WorkLogId] ASC),
    CONSTRAINT [FK_KEDB_AuditWorkLog] FOREIGN KEY ([KAID]) REFERENCES [AVL].[KEDB_TRN_KATicketDetails] ([KAId]),
    CONSTRAINT [FK_KEDB_AuditWorkLog_projectId] FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

