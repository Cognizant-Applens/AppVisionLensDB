CREATE TABLE [AVL].[Audit_PRJ_TicketMasterAuditLog] (
    [ProjectID]         BIGINT          NOT NULL,
    [TicketID]          NVARCHAR (1000) NULL,
    [FieldName]         NVARCHAR (1000) NOT NULL,
    [FromValue]         NVARCHAR (1000) NULL,
    [ToValue]           NVARCHAR (1000) NULL,
    [Action]            NVARCHAR (10)   NULL,
    [ModifiedBy]        NVARCHAR (100)  NULL,
    [ModifiedTimeStamp] DATETIME        NULL
);


GO
CREATE NONCLUSTERED INDEX [TicketID_TK_TRN_TicketDetail]
    ON [AVL].[Audit_PRJ_TicketMasterAuditLog]([TicketID] ASC);

