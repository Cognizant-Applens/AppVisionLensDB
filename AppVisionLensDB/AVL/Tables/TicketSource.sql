CREATE TABLE [AVL].[TicketSource] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [SourceName]   NVARCHAR (100) NULL,
    [Isdeleted]    INT            NULL,
    [CreatedBy]    NVARCHAR (100) NULL,
    [CreatedDate]  DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (100) NULL,
    [ModifiedDate] DATETIME       NULL
);

