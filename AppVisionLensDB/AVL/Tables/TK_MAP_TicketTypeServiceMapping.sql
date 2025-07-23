CREATE TABLE [AVL].[TK_MAP_TicketTypeServiceMapping] (
    [TicketTypeServiceMapID] INT            IDENTITY (1, 1) NOT NULL,
    [ProjectID]              BIGINT         NOT NULL,
    [TicketTypeMappingID]    BIGINT         NULL,
    [ServiceID]              INT            NULL,
    [IsDART]                 INT            NULL,
    [IsDeleted]              BIT            NULL,
    [CreatedDateTime]        DATETIME       NULL,
    [CreatedBY]              NVARCHAR (200) NULL,
    [ModifiedDateTime]       DATETIME       NULL,
    [ModifiedBY]             NVARCHAR (50)  NULL,
    [EffectiveDate]          DATETIME       NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_MAP_TicketTypeServiceMapping_IsDeleted_TicketTypeMappingID]
    ON [AVL].[TK_MAP_TicketTypeServiceMapping]([IsDeleted] ASC, [TicketTypeMappingID] ASC)
    INCLUDE([ProjectID], [ServiceID]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_MAP_TicketTypeServiceMapping_ProjectID_IsDeleted_TicketTypeMappingID]
    ON [AVL].[TK_MAP_TicketTypeServiceMapping]([ProjectID] ASC, [IsDeleted] ASC, [TicketTypeMappingID] ASC)
    INCLUDE([ServiceID]);

