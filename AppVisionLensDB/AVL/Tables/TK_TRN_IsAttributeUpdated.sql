CREATE TABLE [AVL].[TK_TRN_IsAttributeUpdated] (
    [Id]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [TimeTickerID] BIGINT         NOT NULL,
    [ProjectId]    BIGINT         NOT NULL,
    [TicketId]     NVARCHAR (100) NOT NULL,
    [Mode]         NVARCHAR (100) NULL,
    [IsProcessed]  BIT            NULL,
    [IsDeleted]    BIT            NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [CreatedDate]  DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_TRN_IsAttributeUpdated_ProjectId_Mode]
    ON [AVL].[TK_TRN_IsAttributeUpdated]([ProjectId] ASC, [Mode] ASC)
    INCLUDE([TimeTickerID]);

