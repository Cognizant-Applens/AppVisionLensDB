CREATE TABLE [AVL].[TK_MAP_TicketTypeMapping] (
    [TicketTypeMappingID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [TicketType]          VARCHAR (500) NULL,
    [AVMTicketType]       BIGINT        NULL,
    [ProjectID]           INT           NOT NULL,
    [DebtConsidered]      NVARCHAR (10) NULL,
    [IsDeleted]           BIT           NULL,
    [CreatedDateTime]     DATETIME      NULL,
    [CreatedBY]           NVARCHAR (50) NULL,
    [ModifiedDateTime]    DATETIME      NULL,
    [ModifiedBY]          NVARCHAR (50) NULL,
    [IsDefaultTicketType] NVARCHAR (50) NULL,
    [TicketTypeName]      VARCHAR (50)  NULL,
    [SupportTypeID]       INT           NULL,
    CONSTRAINT [PK__TK_MAP_T__0025F895C50DCFAE] PRIMARY KEY CLUSTERED ([TicketTypeMappingID] ASC),
    CONSTRAINT [FK__TK_MAP_Ti__AVMTi__75F77EB0] FOREIGN KEY ([AVMTicketType]) REFERENCES [AVL].[TK_MAS_TicketType] ([TicketTypeID])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TK_MAP_TicketTypeMapping_ProjectID]
    ON [AVL].[TK_MAP_TicketTypeMapping]([ProjectID] ASC)
    INCLUDE([TicketTypeMappingID], [TicketType], [AVMTicketType], [IsDeleted]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TicketTypeMapping]
    ON [AVL].[TK_MAP_TicketTypeMapping]([AVMTicketType] ASC)
    INCLUDE([TicketType], [ProjectID]);

